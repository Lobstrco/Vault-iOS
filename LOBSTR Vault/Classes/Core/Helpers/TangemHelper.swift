import Foundation
import TangemSdk

@available(iOS 13.0, *)
public enum TangemResult<T> {
  case success(T)
  case failure(TangemSdkError)
}

@available(iOS 13.0, *)
struct TangemHelper {
  
  static let tangemSdk = TangemSdk()
  
  static func scanCard(completion: @escaping (TangemResult<Card>) -> Void) {
    tangemSdk.scanCard(initialMessage: Message(header: L10n.scanCardDescription)) { result in
      switch result {
      case .success(let card):
         completion(.success(card))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  static func createWallet(cardId: String, curve: EllipticCurve?, completion: @escaping (TangemResult<CreateWalletResponse>) -> Void) {
    tangemSdk.createWallet(curve: curve ?? .ed25519, cardId: cardId, initialMessage: Message(header: L10n.scanCardDescription)) { result in
      switch result {
      case .success(let createWalletResponse):
        completion(.success(createWalletResponse))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  static func signTransactionHash(hash: Data, cardId: String, completion: @escaping (TangemResult<SignResponse>) -> Void) {
    tangemSdk.sign(hashes: [hash], walletPublicKey: UserDefaultsHelper.tangemPublicKeyData!, cardId: cardId, initialMessage: Message(header: L10n.scanCardDescription)) { result in
      switch result {
      case .success(let signResponse):
        completion(.success(signResponse))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
