import Foundation
import stellarsdk

protocol KeyPairBroadcast {
  var keyPair: KeyPair? { get }
  var error: Error? { get }
}

protocol HorizonTransactionDataBroadcast {
  var xdrEnvelope: String? { get }
  var error: Error? { get }
}

protocol VaultServerTransactionDataBroadcast {
  var xdrEnvelope: String? { get }  
  var horizonResult: (resultCode: TransactionResultCode, operationMessageError: String?)? { get }
  var transactionHash: String? { get }
  var error: Error? { get }
}
