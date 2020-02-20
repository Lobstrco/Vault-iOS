import Foundation

struct MarkTransactionAsSubmittedRequestParameters {
  let xdr: String
  let hash: String
}

struct MarkTransactionAsSubmittedRequest: APIRequest {
  
  func makeRequest(from data: MarkTransactionAsSubmittedRequestParameters?, jwtToken: String?) throws -> URLRequest {
    guard let hash = data?.hash else {
      throw VaultError.TransactionError.invalidTransaction
    }
    
    let path = "/api/transactions/\(hash)/submit/"
    let urlString = Environment.baseURL + path
    let url = URL(string: urlString)!
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = APIRequestHTTPMethod.post.rawValue
    
    guard let data = data else {
      throw VaultError.TransactionError.invalidTransaction
    }
    
    let parameters: [String: Any] = ["xdr": data.xdr]
    
    urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
    
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
