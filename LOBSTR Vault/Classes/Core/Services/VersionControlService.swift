import Foundation

class VersionControlService {
  
  func getAppVersion(completion: @escaping (Result<VersionControl>) -> Void) {
    let apiLoader = APIRequestLoader<VersionControlRequest>(apiRequest: VersionControlRequest())
    apiLoader.loadAPIRequest(requestData: nil) { result in
      switch result {
      case .success(let response):
        completion(.success(response))
      case .failure(let serverRequestError):
        completion(.failure(serverRequestError))
      }
    }
  }
  
}
