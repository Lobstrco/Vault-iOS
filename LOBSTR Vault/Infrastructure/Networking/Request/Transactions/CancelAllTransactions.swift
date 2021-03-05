import Foundation

struct CancelAllTransactionsRequestParameters {}

struct CancelAllTransactionsRequest: APIRequest {
  
  func makeRequest(from data: CancelAllTransactionsRequestParameters?, jwtToken: String?) throws -> URLRequest {
    let path = "/api/transactions/hide-all/"
    let urlString = Environment.baseURL + path
    let url = URL(string: urlString)!
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = APIRequestHTTPMethod.post.rawValue
    
    guard let token = jwtToken else {
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
