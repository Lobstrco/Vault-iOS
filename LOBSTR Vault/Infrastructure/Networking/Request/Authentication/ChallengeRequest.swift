import Foundation

struct ChallengeRequestParameters {
  let account: String
}

struct Challenge: Codable {
  let transaction: String?
}

struct ChallengeRequest: APIRequest {
  
  func makeRequest(from data: ChallengeRequestParameters?, jwtToken: String?) throws -> URLRequest {
    let path = "/api/authentication/"
    let urlString = Environment.baseURL + path
    
    var components = URLComponents(string: urlString)!
    components.queryItems = [
      URLQueryItem(name: "account", value: data?.account)
    ]
    
    var urlRequest = URLRequest(url: components.url!)
    urlRequest.httpMethod = APIRequestHTTPMethod.get.rawValue
    
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    
    return urlRequest
  }
  
  func parseResponse(data: Data) throws -> Challenge {
    return try JSONDecoder().decode(Challenge.self, from: data)
  }
  
}
