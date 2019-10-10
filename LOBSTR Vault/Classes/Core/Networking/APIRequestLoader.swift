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
//      print("JWT: \(jwt)")
      let urlRequest = try apiRequest.makeRequest(from: requestData, jwtToken: jwt)
      
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
                      AuthenticationService().updateToken() { result in
                        switch result {
                        case .success(_):
                          completion(.failure(.needRepeatRequest))
                        case .failure(_):
                          completion(.failure(.unauthorized(message: detail)))
                        }
                      }
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
          do {
            let parsedResponse = try self.apiRequest.parseResponse(data: data)
            DispatchQueue.main.async {
              completion(.success(parsedResponse))
            }
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
