import Foundation

class HomeService {
  
  func getSignedAccounts(completion: @escaping (Result<[SignedAccounts]>) -> Void) {
    let apiLoader = APIRequestLoader<SignedAccountsRequest>(apiRequest: SignedAccountsRequest())
    
    apiLoader.loadAPIRequest(requestData: nil) { result in
      switch result {
      case .success(let paginationResponse):
        completion(.success(paginationResponse.results))
      case .failure(let serverRequestError):
        completion(.failure(serverRequestError))
      }
    }
  }
  
  func getNumberOfTransactions(completion: @escaping (Result<Int>) -> Void) {
    let apiLoader = APIRequestLoader<PendingTransactionListRequest>(apiRequest: PendingTransactionListRequest())
    
    apiLoader.loadAPIRequest(requestData: nil) { result in
      switch result {
      case .success(let paginationResponse):
        completion(.success(paginationResponse.count))
      case .failure(let serverRequestError):
        completion(.failure(serverRequestError))
      }
    }
  }
}
