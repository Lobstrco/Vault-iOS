import Foundation
import TangemSdk

public enum TangemResult<T> {
  case success(T)
  case failure(SessionError)
}

struct TangemHelper {
      
  static func scanCard(completion: @escaping (TangemResult<Card>) -> Void) {
    let tangemSdk = TangemSdk()
    tangemSdk.scanCard { result in
      switch result {
      case .success(let card):
         completion(.success(card))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  @available(iOS 13.0, *)
  static func createWallet(cardId: String, completion: @escaping (TangemResult<CreateWalletResponse>) -> Void) {
    let tangemSdk = TangemSdk()
    tangemSdk.createWallet(cardId: cardId) { result in
      switch result {
      case .success(let createWalletResponse):
        completion(.success(createWalletResponse))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  @available(iOS 13.0, *)
  static func signTransactionHash(hash: Data, cardId: String, completion: @escaping (TangemResult<SignResponse>) -> Void) {
    let tangemSdk = TangemSdk()
    tangemSdk.sign(hashes: [hash], cardId: cardId) { result in
      switch result {
      case .success(let signResponse):
        completion(.success(signResponse))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
