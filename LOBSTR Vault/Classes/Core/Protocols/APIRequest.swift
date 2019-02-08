import Foundation

protocol APIRequest {
  associatedtype RequestDataType
  associatedtype ResponseDataType
  
  func makeRequest(from data: RequestDataType?, jwtToken: String?) throws -> URLRequest
  func parseResponse(data: Data) throws -> ResponseDataType
}

enum APIRequestHTTPMethod: String {
  case post = "POST"
  case put = "PUT"
  case get = "GET"
  case delete = "DELETE"
}
