import Foundation

enum NetworkingResult<T> {
  case success(T)
  case failure(_ error: ServerRequestError)
}
