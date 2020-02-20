import Foundation

struct AccountConfig: Codable {
  let spamProtectionEnabled: Bool?
}

struct AccountConfigParameters: Codable {
  let spamProtectionEnabled: Bool?
}

struct AccountConfigRequest: APIRequest {
  
  func makeRequest(from data: AccountConfigParameters?, jwtToken: String?) throws -> URLRequest {
    let path = "/api/account/config/"
    let urlString = Environment.baseURL + path
    let url = URL(string: urlString)!
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = APIRequestHTTPMethod.get.rawValue
    
    if let token = jwtToken {
      let autrhorizationHeaderField = "Authorization"
      urlRequest.addValue("JWT \(token)", forHTTPHeaderField: autrhorizationHeaderField)
    }
    
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    
    return urlRequest
  }
  
  func parseResponse(data: Data) throws -> AccountConfig {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(AccountConfig.self, from: data)
  }
}
