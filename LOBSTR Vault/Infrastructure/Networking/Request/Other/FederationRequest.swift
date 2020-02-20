import Foundation

struct FederationRequestParameters {
  let publicKey: String
  let type: FederationType
}

enum FederationType: String {
  case name, id, forward, txid
}

struct Federation: Codable {
  let stellarAddress: String?
  let accountId: String?
}

struct FederationRequest: APIRequest {
  
  func makeRequest(from data: FederationRequestParameters?, jwtToken: String?) throws -> URLRequest {
    let path = "/federation/"
    let urlString = Constants.baseLobstrURL + path
    var urlComponents = URLComponents(string: urlString)!
    
    if let data = data {
      urlComponents.queryItems = [URLQueryItem(name: "q", value: data.publicKey),
                                  URLQueryItem(name: "type", value: data.type.rawValue)]
    }
    
    var urlRequest = URLRequest(url: urlComponents.url!)
    urlRequest.httpMethod = APIRequestHTTPMethod.get.rawValue
    
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    
    return urlRequest
  }
  
  func parseResponse(data: Data) throws -> Federation {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(Federation.self, from: data)
  }
  
}
