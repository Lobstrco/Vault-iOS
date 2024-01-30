import Foundation

public struct Account: Codable {
  var publicKey: String
  var federation: String?
  
  static func encode(_ account: Account) -> Data? {
    return try? JSONEncoder().encode(account)
  }
  
  static func decode(_ data: Data) -> Account? {
    return try? JSONDecoder().decode(Account.self, from: data)
  }
}

struct FederationService {
  public func getFederation(for publicKey: String, type: FederationType = .id, completion: @escaping (Result<Account>) -> Void) {
    let apiLoader = APIRequestLoader<FederationRequest>(apiRequest: FederationRequest())
    let data = FederationRequestParameters(publicKey: publicKey, type: type)
    
    apiLoader.loadAPIRequest(requestData: data) { result in
      switch result {
      case .success(let federation):
        let account = self.saveAccount(with: publicKey, federation: federation.stellarAddress)
        completion(.success(account))
      case .failure(let serverRequestError):
        switch serverRequestError {
        case .notFound(_):
          _ = self.saveAccount(with: publicKey, federation: nil)
          completion(.failure(serverRequestError))
        default:
          completion(.failure(serverRequestError))
        }
      }
    }
  }
    
  private func saveAccount(with publicKey: String, federation: String?) -> Account {
    let storage: AccountsStorage = AccountsStorageDiskImpl()
    var storageAccounts = AccountsStorageHelper.getStoredAccounts()
    
    if let index = storageAccounts.firstIndex(where: { $0.address == publicKey }) {
      storageAccounts[index].federation = federation
      storage.save(accounts: storageAccounts)
      let account = Account(publicKey: publicKey, federation: federation)
      return account
    } else {
      let signedAccount = SignedAccount(address: publicKey, federation: federation, nickname: nil, indicateAddress: AccountsStorageHelper.indicateAddress)
      storageAccounts.append(signedAccount)
      storage.save(accounts: storageAccounts)
      let account = Account(publicKey: publicKey, federation: federation)
      return account
    }
  }
}
