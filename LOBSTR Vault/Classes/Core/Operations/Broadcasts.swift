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
  var horizonResultCode: TransactionResultCode? { get }
  var error: Error? { get }
}
