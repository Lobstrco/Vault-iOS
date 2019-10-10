import Foundation

public enum ServerRequestError: Error {
  case requestFailed(message: String)
  case emptyResponse
  case parsingResponseFailed(message: String)

  case badRequest(message: String) // HTTP Status Code 400
  case unauthorized(message: String) // HTTP Status Code 401
  case forbidden(message: String) // HTTP Status Code 403
  case notFound(message: String) // HTTP Status Code 404
  
  case needRepeatRequest //
}
