import Foundation

struct SubmitChallengeRequestParameters {
  let transaction: String
}

struct JWTToken: Codable {
  let token: String?
}

struct SubmitChallengeRequest: APIRequest {
  
  func makeRequest(from data: SubmitChallengeRequestParameters?, jwtToken: String?) throws -> URLRequest {
    let path = "/api/authentication/"
    let urlString = Environment.baseURL + path
    let url = URL(string: urlString)!
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = APIRequestHTTPMethod.post.rawValue
    
    if let transaction = data?.transaction {
      let parameters: [String: String] = ["transaction": transaction]
      urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
    }
    
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    
    return urlRequest
  }
  
  func parseResponse(data: Data) throws -> JWTToken {
    return try JSONDecoder().decode(JWTToken.self, from: data)
  }
}
