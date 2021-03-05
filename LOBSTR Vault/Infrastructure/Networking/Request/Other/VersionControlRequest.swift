import Foundation

struct VersionControlRequestParameters {}

struct VersionControl: Codable {
  let currentVersion: String?
  let minVersion: String?
  let recommendedVersion: String?

  enum CodingKeys: String, CodingKey {
    case currentVersion = "current_version"
    case minVersion = "min_app_version"
    case recommendedVersion = "recommended"
  }
}
struct VersionControlRequest: APIRequest {
  
  func makeRequest(from data: VersionControlRequestParameters?, jwtToken: String?) throws -> URLRequest {
    let path = "/api/version-control/ios/"
    let urlString = Environment.baseURL + path
    
    let url = URL(string: urlString)!
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = APIRequestHTTPMethod.get.rawValue
    
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    
    return urlRequest

  }
  
  func parseResponse(data: Data) throws -> VersionControl {
    return try JSONDecoder().decode(VersionControl.self, from: data)
  }
  
}
