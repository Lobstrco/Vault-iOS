import Foundation

struct FederationService {
  
  public func getFederation(for publicKey: String, type: FederationType = .id, completion: @escaping (Result<Account>) -> Void) {
    let apiLoader = APIRequestLoader<FederationRequest>(apiRequest: FederationRequest())
    let data = FederationRequestParameters(publicKey: publicKey, type: type)
    
    apiLoader.loadAPIRequest(requestData: data) { result in
      switch result {
      case .success(let federation):
        let savedAccount = self.saveAccountToBD(with: publicKey, federation: federation.stellarAddress)
        completion(.success(savedAccount))
      case .failure(let serverRequestError):
        switch serverRequestError {
        case .notFound(_):
          _ = self.saveAccountToBD(with: publicKey, federation: nil)
        default:
          completion(.failure(serverRequestError))
        }
      }
    }
  }
  
  private func saveAccountToBD(with publicKey: String, federation: String?) -> Account {
    let account = CoreDataStack.shared.create(Account.fetchBy(publicKey: publicKey))
    account.federation = federation
    account.publicKey = publicKey
    CoreDataStack.shared.saveContext()
    
    return account
  }
}
