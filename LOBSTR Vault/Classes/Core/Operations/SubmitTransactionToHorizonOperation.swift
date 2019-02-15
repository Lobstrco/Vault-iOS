import Foundation
import stellarsdk

class SubmitTransactionToHorizonOperation: AsyncOperation {
  
  private var outputHorizonResultCode: TransactionResultCode?
  private var outputXdrEnvelope: String?
  
  private var inputXdrEnvelope: String?
  
  override func start() {
    getDependencies()
    super.start()
  }
  
  override func main() {    
    StellarSDK(withHorizonUrl: Constants.horizonURL).transactions.postTransaction(transactionEnvelope: inputXdrEnvelope!) { (response) -> (Void) in
      switch response {
      case .success(_):
        self.outputHorizonResultCode = .success
        self.finished(error: nil)
      case .failure(let error):
        self.tryToResolveFailure(with: error)
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
      self.outputHorizonResultCode = try! TransactionHelper.getTransactionResultCode(from: message)
      self.finished(error: nil)
    default:
      self.finished(error: error)
    }
  }
}

// MARK: - Output

extension SubmitTransactionToHorizonOperation: VaultServerTransactionDataBroadcast {
  var xdrEnvelope: String? { return outputXdrEnvelope }
  var horizonResultCode: TransactionResultCode? { return outputHorizonResultCode }
  var error: Error? { return outputError }
}
