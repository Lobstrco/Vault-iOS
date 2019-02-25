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
      let transactionHash = try [UInt8](envelope.tx.hash(network: .public))
      let userSignature = keyPair.signDecorated(transactionHash)
      envelope.signatures.append(userSignature)
      outputXdrEncodedEnvelope = envelope.xdrEncoded
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
