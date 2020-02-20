import Foundation

struct SubmitSignedTransactionRequestParameters {
  let xdr: String
}

struct SubmitSignedTransactionRequest: APIRequest {
  
  func makeRequest(from data: SubmitSignedTransactionRequestParameters?, jwtToken: String?) throws -> URLRequest {
    let path = "/api/transactions/"
    let urlString = Environment.baseURL + path
    let url = URL(string: urlString)!

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = APIRequestHTTPMethod.post.rawValue

    guard let data = data else {
      throw VaultError.TransactionError.invalidTransaction
    }
    
    let parameters: [String: Any] = ["xdr": data.xdr]    
    
    urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
    
    if let token = jwtToken {
      let autrhorizationHeaderField = "Authorization"
      urlRequest.addValue("JWT \(token)", forHTTPHeaderField: autrhorizationHeaderField)
    }
    
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

    return urlRequest
  }

  func parseResponse(data: Data) throws -> Any? {
    return nil
  }
}
