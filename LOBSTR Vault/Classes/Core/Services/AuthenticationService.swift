import Foundation
import stellarsdk

class AuthenticationService {
  let jwtManager: JWTManager = JWTManagerImpl()
  let mnemonicManager: MnemonicManager = MnemonicManagerImpl()
  
  func updateTokenWithTangem(publicKey: String, walletPublicKey: Data, cardId: String, completion: @escaping (Result<String>) -> Void) {
    let challengeRequestParameters = ChallengeRequestParameters(account: publicKey)
    let apiLoader = APIRequestLoader<ChallengeRequest>(apiRequest: ChallengeRequest())
    apiLoader.loadAPIRequest(requestData: challengeRequestParameters) { result in
      switch result {
      case .success(let challenge):
        do {
          guard let transaction = challenge.transaction else {
            return
              // completion(.failure(error))
          }
          var envelope = TransactionHelper.tryToTransformTransactionXDRV0ToV1(envelopeXDR: try TransactionEnvelopeXDR(xdr: transaction))
                    
          guard let hash = try? envelope.txHash(network: .public) else {
            Logger.auth.error("Couldn't get transaction hash")
            return
          }
          
          guard #available(iOS 13.0, *) else { return }
          TangemHelper.signTransactionHash(hash: hash, cardId: cardId) { result in
            switch result {
            case .success(let signedTransaction):
              TransactionHelper.signTransaction(walletPublicKey: walletPublicKey,
                                                signature: signedTransaction.signature,
                                                txEnvelope: &envelope)
                            
              guard let signedTransaction = envelope.xdrEncoded else {
                Logger.auth.error("Couldn't encoded xdr")
                return
              }
              Logger.tangem.debug("Signed transaction: \(signedTransaction)")
              let submitChallengeRequestParameters = SubmitChallengeRequestParameters(transaction: signedTransaction)
              let apiLoader = APIRequestLoader<SubmitChallengeRequest>(apiRequest: SubmitChallengeRequest())
              apiLoader.loadAPIRequest(requestData: submitChallengeRequestParameters) { result in
                switch result {
                case .success(let jwtToken):
                  guard let token = jwtToken.token else {
                    // completion(.failure(error))
                    return
                  }
                  Logger.auth.debug("JWT Token was updated: \(token)")
                  guard self.jwtManager.store(token, for: "") else { return }
                  completion(.success(token))
                case .failure(let error):
                  completion(.failure(error))
                }
              }
            case .failure(let error):
              completion(.failure(error))
            }
          }
        } catch let error {
          completion(.failure(error))
        }
      case .failure(let serverRequestError):
        completion(.failure(serverRequestError))
      }
    }
  }
  
  func getToken(for index: Int, completion: @escaping (Result<[String: String]>) -> Void) {
    guard mnemonicManager.isMnemonicStoredInKeychain() else {
      Logger.mnemonic.error("Mnemonic doesn't exist")
      return
    }
    
    mnemonicManager.getDecryptedMnemonicFromKeychain { result in
      switch result {
      case .success(let mnemonic):
        let keyPair = MnemonicHelper.getKeyPairFrom(mnemonic, index: index)
        let challengeRequestParameters = ChallengeRequestParameters(account: keyPair.accountId)
        let apiLoader = APIRequestLoader<ChallengeRequest>(apiRequest: ChallengeRequest())
        apiLoader.loadAPIRequest(requestData: challengeRequestParameters) { result in
          switch result {
          case .success(let challenge):
            do {
              guard let transaction = challenge.transaction else {
                return
              }
              var envelope = TransactionHelper.tryToTransformTransactionXDRV0ToV1(envelopeXDR: try TransactionEnvelopeXDR(xdr: transaction))
              try TransactionHelper.signTransaction(transactionEnvelopeXDR: &envelope, userKeyPair: keyPair)
              if let signedTransaction = envelope.xdrEncoded {
                let submitChallengeRequestParameters = SubmitChallengeRequestParameters(transaction: signedTransaction)
                let apiLoader = APIRequestLoader<SubmitChallengeRequest>(apiRequest: SubmitChallengeRequest())
                apiLoader.loadAPIRequest(requestData: submitChallengeRequestParameters) { result in
                  switch result {
                  case .success(let jwtToken):
                    guard let token = jwtToken.token else {
                      return
                    }
                    Logger.auth.debug("JWT Token was got: \(token)")
                    completion(.success([keyPair.accountId: token]))
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
  
  
  func updateToken(for index: Int = UserDefaultsHelper.activePublicKeyIndex,
                   with token: String = "",
                   completion: @escaping (Result<String>) -> Void) {
    guard mnemonicManager.isMnemonicStoredInKeychain() else {
      Logger.mnemonic.error("Mnemonic doesn't exist")
      return
    }
    
    mnemonicManager.getDecryptedMnemonicFromKeychain { result in
      switch result {
      case .success(let mnemonic):
        let keyPair = MnemonicHelper.getKeyPairFrom(mnemonic, index: index)
        let challengeRequestParameters = ChallengeRequestParameters(account: keyPair.accountId)
        let apiLoader = APIRequestLoader<ChallengeRequest>(apiRequest: ChallengeRequest())
        apiLoader.loadAPIRequest(requestData: challengeRequestParameters, jwtToken: token) { result in
          switch result {
          case .success(let challenge):
            do {
              guard let transaction = challenge.transaction else {
                return
                  // completion(.failure(error))
              }
              var envelope = TransactionHelper.tryToTransformTransactionXDRV0ToV1(envelopeXDR: try TransactionEnvelopeXDR(xdr: transaction))
              try TransactionHelper.signTransaction(transactionEnvelopeXDR: &envelope, userKeyPair: keyPair)
              if let signedTransaction = envelope.xdrEncoded {
                let submitChallengeRequestParameters = SubmitChallengeRequestParameters(transaction: signedTransaction)
                let apiLoader = APIRequestLoader<SubmitChallengeRequest>(apiRequest: SubmitChallengeRequest())
                apiLoader.loadAPIRequest(requestData: submitChallengeRequestParameters) { result in
                  switch result {
                  case .success(let jwtToken):
                    guard let token = jwtToken.token else {
                      // completion(.failure(error))
                      return
                    }
                    Logger.auth.debug("JWT Token was updated: \(token)")
                    guard self.jwtManager.store(token, for: keyPair.accountId) else { return }
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
}
