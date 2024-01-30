import Foundation
import stellarsdk

class SignTransactionWithTangemOperation: AsyncOperation {
  
  private let transactionEnvelopeXDR: TransactionEnvelopeXDR?
  private var outputXdrEncodedEnvelope: String?
  
  init(transactionEnvelopeXDR: TransactionEnvelopeXDR?) {
    self.transactionEnvelopeXDR = transactionEnvelopeXDR
    super.init()
  }
  
  override func main() {
    guard let xdr = transactionEnvelopeXDR else { return }
    var envelope = TransactionHelper.tryToTransformTransactionXDRV0ToV1(envelopeXDR: xdr)
        
    guard let hash = try? envelope.txHash(network: .public) else {
      return
    }
    
    guard #available(iOS 13.0, *) else { return }
    TangemHelper.signTransactionHash(hash: hash, cardId: UserDefaultsHelper.tangemCardId!) { result in
      switch result {
      case .success(let signedTransaction):
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
          NotificationCenter.default.post(name: .didSignCardScan, object: nil)
        }
        guard let signature = signedTransaction.signatures.first else { return }
        TransactionHelper.signTransaction(walletPublicKey: UserDefaultsHelper.tangemPublicKeyData!,
                                          signature: signature,
                                          txEnvelope: &envelope)
        self.outputXdrEncodedEnvelope = envelope.xdrEncoded
        self.finished(error: nil)
      case .failure(let sessionError):
        self.finished(error: sessionError)
      }
    }
  }
}

// MARK: - Output

extension SignTransactionWithTangemOperation: HorizonTransactionDataBroadcast {
  var xdrEnvelope: String? { return outputXdrEncodedEnvelope }
  var error: Error? { return outputError }
}
