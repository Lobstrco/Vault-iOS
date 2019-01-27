import Foundation

struct SignedAccountsRequest: APIRequest {
  
  func makeRequest(from data: SignedAccountsRequest?, jwtToken: String?) throws -> URLRequest {
    let path = "/api/signed-accounts/"
    let urlString = Constants.baseURL + path
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
  
  func parseResponse(data: Data) throws -> PaginationResponse<SignedAccounts> {
    return try JSONDecoder().decode(PaginationResponse<SignedAccounts>.self, from: data)
  }
  
}
