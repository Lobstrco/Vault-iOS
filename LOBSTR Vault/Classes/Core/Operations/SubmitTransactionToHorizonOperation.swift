import Foundation
import stellarsdk

class SubmitTransactionToHorizonOperation: AsyncOperation {
  
  private var outputHorizonResult: (resultCode: TransactionResultCode, operaiotnMessageError: String?)?
  private var outputXdrEnvelope: String?
  private var outputTransactionHash: String?
  
  private var inputXdrEnvelope: String?
  
  override func start() {
    getDependencies()
    super.start()
  }
  
  override func main() {
    StellarSDK(withHorizonUrl: Environment.horizonBaseURL).transactions.postTransaction(transactionEnvelope: inputXdrEnvelope!) { (response) -> (Void) in
      switch response {
      case .success(let info):
        self.outputHorizonResult = (.success, nil)
        self.outputTransactionHash = info.transactionHash
        self.finished(error: nil)
      case .failure(let error):
        self.tryToResolveFailure(with: error)
      case .destinationRequiresMemo(_):
        self.finished(error: nil)
      }
    }
  }
}

// MARK: - Private

extension SubmitTransactionToHorizonOperation {
  
  private func getDependencies() {
    if let dataProvider = dependencies
      .filter({ $0 is HorizonTransactionDataBroadcast })
      .first as? HorizonTransactionDataBroadcast {
      
      inputXdrEnvelope = dataProvider.xdrEnvelope
      outputError = dataProvider.error
    }
    
    outputXdrEnvelope = inputXdrEnvelope
  }
  
  private func tryToResolveFailure(with error: HorizonRequestError) {
    switch error {
    case .badRequest(let message, _):
      self.outputHorizonResult = try? TransactionHelper.getTransactionResult(from: message)
      self.finished(error: nil)
    default:
      self.finished(error: error)
    }
  }
}

// MARK: - Output

extension SubmitTransactionToHorizonOperation: VaultServerTransactionDataBroadcast {
  var xdrEnvelope: String? { return outputXdrEnvelope }
  var horizonResult: (resultCode: TransactionResultCode, operaiotnMessageError: String?)? { return outputHorizonResult }
  var transactionHash: String? { return outputTransactionHash }
  var error: Error? { return outputError }
}
