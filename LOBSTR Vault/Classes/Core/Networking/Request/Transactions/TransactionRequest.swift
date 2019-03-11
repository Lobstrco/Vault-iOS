import Foundation

struct TransactionRequestParameters {
  let hash: String
}

class TransactionRequest: APIRequest {
  
  func makeRequest(from data: TransactionRequestParameters?, jwtToken: String?) throws -> URLRequest {
    guard let data = data else {
      throw VaultError.TransactionError.invalidTransaction
    }
    
    let path = "/api/transactions/\(data.hash)/"
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
  
  func parseResponse(data: Data) throws -> Transaction {
    return try JSONDecoder().decode(Transaction.self, from: data)
  }
}
