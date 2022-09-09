import Foundation

struct SequenceNumberCountParameters: Codable {
  let account: String
  let sequenceNumber: Int
}

struct SequenceNumberCount: Codable {
  let count: Int?
}

struct SequenceNumberCountRequest: APIRequest {
  
  func makeRequest(from data: SequenceNumberCountParameters?, jwtToken: String?) throws -> URLRequest {
    guard let account = data?.account,
          let sequenceNumber = data?.sequenceNumber
    else {
      throw VaultError.TransactionError.invalidTransaction
    }
    
    let path = "/api/count-sequence-number/\(account)/\(sequenceNumber)"
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
  
  func parseResponse(data: Data) throws -> SequenceNumberCount {
    let decoder = JSONDecoder()
    return try decoder.decode(SequenceNumberCount.self, from: data)
  }
}
