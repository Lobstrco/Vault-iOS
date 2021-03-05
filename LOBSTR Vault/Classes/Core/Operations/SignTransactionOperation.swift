import Foundation
import stellarsdk

class SignTransactionOperation: AsyncOperation {
  
  private let transactionEnvelopeXDR: TransactionEnvelopeXDR?
  private var outputXdrEncodedEnvelope: String?
  
  var inputKeyPair: KeyPair? {
    var keyPair: KeyPair?
    
    if let dataProvider = dependencies.first as? KeyPairBroadcast {
      keyPair = dataProvider.keyPair
      outputError = dataProvider.error
    }
    
    return keyPair
  }
  
  init(transactionEnvelopeXDR: TransactionEnvelopeXDR?) {
    self.transactionEnvelopeXDR = transactionEnvelopeXDR
    super.init()
  }
  
  override func main() {
    guard let keyPair = inputKeyPair, let envelope = transactionEnvelopeXDR else {
      finished(error: VaultError.VaultStorageError.keychainDataNotFound)
      return
    }
    
    do {
//      let transaction = try! stellarsdk.Transaction(envelopeXdr: envelope.xdrEncoded!)
//      try! transaction.sign(keyPair: keyPair, network: .public)
//      let xdrEnvelope = try! transaction.encodedEnvelope()
//      outputXdrEncodedEnvelope = xdrEnvelope
      
//      let transactionHash = try [UInt8](envelope.txHash(network: .public))
//      let userSignature = keyPair.signDecorated(transactionHash)
//      envelope.appendSignature(signature: userSignature)
      
//      guard var env = TransactionHelper.getTransactionV1Envelope(envelope: envelope) else {
//        finished(error: VaultError.VaultStorageError.keychainDataNotFound)
//        return
//      }
      
      var transactionEnvelope = TransactionHelper.tryToTransformTransactionXDRV0ToV1(envelopeXDR: envelope)
      try TransactionHelper.signTransaction(transactionEnvelopeXDR: &transactionEnvelope, userKeyPair: keyPair)
      outputXdrEncodedEnvelope = transactionEnvelope.xdrEncoded
      
      finished(error: nil)
    } catch _ {
      finished(error: VaultError.VaultStorageError.keychainDataNotFound)
      return
    }
  }
}

// MARK: - Output

extension SignTransactionOperation: HorizonTransactionDataBroadcast {  
  var xdrEnvelope: String? { return outputXdrEncodedEnvelope }
  var error: Error? { return outputError }
}
