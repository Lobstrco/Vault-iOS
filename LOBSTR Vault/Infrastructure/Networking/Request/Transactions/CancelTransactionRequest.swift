import Foundation

struct CancelTransactionRequestParameters {
  let hash: String
}

struct CancelTransactionRequest: APIRequest {
  
  func makeRequest(from data: CancelTransactionRequestParameters?, jwtToken: String?) throws -> URLRequest {
    guard let hash = data?.hash else {      
      throw VaultError.TransactionError.invalidTransaction
    }
    
    let path = "/api/transactions/\(hash)/cancel/"
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
