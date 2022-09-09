//

import Foundation

struct SignerAddress: Codable {
  let address: String
}

struct ChecksSignersRequestData {
  let signers: [SignerAddress]
}

struct SignerStatus: Codable {
  let address: String
  let isExist: Bool
  
  enum CodingKeys: String, CodingKey {
    case address
    case isExist = "exists"
  }
}

struct CheckSignerRequest: APIRequest {
      
  func makeRequest(from data: ChecksSignersRequestData?, jwtToken: String?) throws -> URLRequest {
    
    let path = "/api/check-user/"
    let urlString = Environment.baseURL + path
    let url = URL(string: urlString)!
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = APIRequestHTTPMethod.post.rawValue
    
    if let token = jwtToken {
      let autrhorizationHeaderField = "Authorization"
      urlRequest.addValue("JWT \(token)", forHTTPHeaderField: autrhorizationHeaderField)
    }
    
    if let data = data {
      let data = try? JSONEncoder().encode(data.signers)
      urlRequest.httpBody = data
    }
    
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    
    return urlRequest
  }
  
  func parseResponse(data: Data) throws -> [SignerStatus] {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode([SignerStatus].self, from: data)
  }
}
