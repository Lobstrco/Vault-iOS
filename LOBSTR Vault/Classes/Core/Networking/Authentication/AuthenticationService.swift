import Foundation
import stellarsdk

class AuthenticationService {
  let jwtManager: JWTManager = JWTManagerImpl()
  let mnemonicManager: MnemonicManager = MnemonicManagerImpl()
  
  func updateToken(completion: @escaping (Result<String>) -> Void) {
    guard mnemonicManager.isMnemonicStoredInKeychain() else {
      return
    }
    
    mnemonicManager.getDecryptedMnemonicFromKeychain { result in
      switch result {
      case .success(let mnemonic):
        let keyPair = MnemonicHelper.getKeyPairFrom(mnemonic)
        let challengeRequestParameters = ChallengeRequestParameters(account: keyPair.accountId)
        let apiLoader = APIRequestLoader<ChallengeRequest>(apiRequest: ChallengeRequest())
        apiLoader.loadAPIRequest(requestData: challengeRequestParameters) { result in
          switch result {
          case .success(let challenge):
            do {
              guard let transaction = challenge.transaction else {
                return
                  // completion(.failure(error))
              }
              
              let transactionEnvelope = try TransactionEnvelopeXDR(xdr: transaction)
              if let signedTransaction = self.signTransaction(transactionEnvelopeXDR: transactionEnvelope, userKeyPair: keyPair) {
                let submitChallengeRequestParameters = SubmitChallengeRequestParameters(transaction: signedTransaction)
                let apiLoader = APIRequestLoader<SubmitChallengeRequest>(apiRequest: SubmitChallengeRequest())
                apiLoader.loadAPIRequest(requestData: submitChallengeRequestParameters) { result in
                  switch result {
                  case .success(let jwtToken):
                    guard let token = jwtToken.token else {
                      // completion(.failure(error))
                      return
                    }
                    guard self.jwtManager.store(token) else { return }
                    completion(.success(token))
                  case .failure(let error):
                    completion(.failure(error))
                  }
                }
              }
            } catch let error {
              completion(.failure(error))
            }
          case .failure(let serverRequestError):
            completion(.failure(serverRequestError))
          }
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  // MARK: - Private Methods
  
  private func signTransaction(transactionEnvelopeXDR: TransactionEnvelopeXDR, userKeyPair: KeyPair) -> String? {
    let envelopeXDR = transactionEnvelopeXDR
    do {
      let tx = envelopeXDR.tx
      
      let transactionHash = try [UInt8](tx.hash(network: .public))
      let userSignature = userKeyPair.signDecorated(transactionHash)
      
      envelopeXDR.signatures.append(userSignature)
      
      if let xdrEncodedEnvelope = envelopeXDR.xdrEncoded {
        return xdrEncodedEnvelope
      } else {
        return nil
      }
    } catch _ {
      return nil
    }
  }
}
