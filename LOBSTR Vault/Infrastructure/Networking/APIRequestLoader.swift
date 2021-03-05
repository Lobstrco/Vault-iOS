import Foundation

final class APIRequestLoader<T: APIRequest> {
  let apiRequest: T
  let urlSession: URLSession
  let jwtManager: JWTManager
  
  init(apiRequest: T, urlSession: URLSession = .shared, jwtManager: JWTManager = JWTManagerImpl()) {
    self.apiRequest = apiRequest
    self.urlSession = urlSession
    self.jwtManager = jwtManager
  }
  
  func loadAPIRequest(requestData: T.RequestDataType?,
                      completion: @escaping (NetworkingResult<T.ResponseDataType>) -> Void) {
    do {
      let jwt = jwtManager.getJWT()
      var urlRequest = try apiRequest.makeRequest(from: requestData, jwtToken: jwt)
      urlRequest.setValue(UserAgentInfo.getFormattedUserAgent(),
                          forHTTPHeaderField: "User-Agent")
      urlRequest.setValue("https://vault.lobstr.co/", forHTTPHeaderField: "Referer")
      Logger.networking.debug("""
                              Request: \(urlRequest.url ?? URL(string: "unknown")!)
                              HttpMethod: \(urlRequest.httpMethod ?? "unknown")
                              HttpBody:\n\(urlRequest.httpBody?.prettyPrintedJSONString ?? "")
                              Headers:\n\(urlRequest.allHTTPHeaderFields ?? [:])
                              With JWT Token:\n\(jwt ?? "unknown")
                              """)
      
      
      urlSession.dataTask(with: urlRequest) { data, response, error in
        
        if let error = error {
          completion(.failure(.requestFailed(message: error.localizedDescription)))
        }
        
        if let httpResponse = response as? HTTPURLResponse {
          switch httpResponse.statusCode {
          case 200..<300:
            break
          case 400: // Bad request
            if let data = data {
              do {
                if let errorJSON = try JSONSerialization.jsonObject(with: data) as? [String: String] {
                  if let detail = errorJSON["error"] {
                    DispatchQueue.main.async {
                      completion(.failure(.badRequest(message: detail)))
                    }
                    return
                  }
                }
              } catch {
                DispatchQueue.main.async {
                  completion(.failure(.badRequest(message: "Bad request")))
                }
                return
              }
            }
          case 401: // Unauthorized
            if let data = data {
              do {
                if let errorJSON = try JSONSerialization.jsonObject(with: data) as? [String: String] {
                  if let detail = errorJSON["detail"] {
                    DispatchQueue.main.async {
                      completion(.failure(.unauthorized(message: detail)))
                    }
                    return
                  }
                }
              } catch {
                DispatchQueue.main.async {
                  completion(.failure(.forbidden(message: "Forbidden")))
                }
                return
              }
            }
          case 403: // Forbidden
            if let data = data {
              do {
                if let errorJSON = try JSONSerialization.jsonObject(with: data) as? [String: String] {
                  if let detail = errorJSON["detail"] {
                    DispatchQueue.main.async {
                      completion(.failure(.forbidden(message: detail)))
                    }
                    return
                  }
                }
              } catch {
                DispatchQueue.main.async {
                  completion(.failure(.forbidden(message: "Forbidden")))
                }
                return
              }
            }
          case 404: // Not found
            DispatchQueue.main.async {
              completion(.failure(.notFound(message: "Not found")))
            }
            return
          default: // Default request failed
            DispatchQueue.main.async {
              completion(.failure(.requestFailed(message: "Request failed")))
            }
            return
          }
        }
        // Parsing response
        if let data = data {
          Logger.networking.debug("Parsing JSON:\n \(data.prettyPrintedJSONString ?? "empty data")")
          do {
            let parsedResponse = try self.apiRequest.parseResponse(data: data)
            DispatchQueue.main.async {
              completion(.success(parsedResponse))
            }
          } catch let DecodingError.typeMismatch(_, errorContext) {
            let errorInfo = "Failed parse JSON: \(String(data: data, encoding: .utf8) ?? "unknown") to type \(String(describing: T.self))\nType mismatch: \(errorContext.debugDescription)"
            Logger.networking.fault(errorInfo)
            completion(.failure(.parsingResponseFailed(message: errorInfo)))
          } catch let DecodingError.valueNotFound(_, errorContext) {
            let errorInfo = "Failed parse JSON: \(String(data: data, encoding: .utf8) ?? "unknown") to type \(String(describing: T.self))\nValue not found: \(errorContext.debugDescription)"
            Logger.networking.fault(errorInfo)
            completion(.failure(.parsingResponseFailed(message: errorInfo)))
          } catch let DecodingError.keyNotFound(key, errorContext) {
            let errorInfo = "Failed parse JSON: \(String(data: data, encoding: .utf8) ?? "unknown") to type \(String(describing: T.self))\nKey not found: \(key.debugDescription). \(errorContext.debugDescription)"
            Logger.networking.fault(errorInfo)
            completion(.failure(.parsingResponseFailed(message: errorInfo)))
          } catch let DecodingError.dataCorrupted(errorContext) {
              let errorInfo = "Failed parse JSON: \(String(data: data, encoding: .utf8) ?? "unknown") to type \(String(describing: T.self))\nnData corrupted: \(errorContext.debugDescription). \(errorContext.debugDescription)"
            Logger.networking.fault(errorInfo)
            completion(.failure(.parsingResponseFailed(message: errorInfo)))
          } catch {
            DispatchQueue.main.async {
              completion(.failure(.parsingResponseFailed(message: "Parsing error. Something went wrong.")))
            }
          }
        } else {
          DispatchQueue.main.async {
            completion(.failure(.emptyResponse))
          }
        }
      }.resume()
    } catch {
      DispatchQueue.main.async {
        completion(.failure(.requestFailed(message: "Something went wrong.")))
      }
      return
    }
  }
}
