import Foundation

struct CancelOutdatedTransactionsRequestParameters {}

struct CancelOutdatedTransactionsRequest: APIRequest {
  
  func makeRequest(from data: CancelOutdatedTransactionsRequestParameters?, jwtToken: String?) throws -> URLRequest {
    let path = "/api/transactions/hide-outdated/"
    let urlString = Environment.baseURL + path
    let url = URL(string: urlString)!
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = APIRequestHTTPMethod.post.rawValue
    
    guard let token = jwtToken else {
      // rewrite
      throw VaultError.TransactionError.invalidTransaction
    }
    
    let autrhorizationHeaderField = "Authorization"
    urlRequest.addValue("JWT \(token)", forHTTPHeaderField: autrhorizationHeaderField)
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    
    return urlRequest
  }
  
  func parseResponse(data: Data) throws -> Any? {
    return nil
  }
}
