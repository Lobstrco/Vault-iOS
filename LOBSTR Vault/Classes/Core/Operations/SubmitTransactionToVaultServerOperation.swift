import Foundation
import stellarsdk

class SubmitTransactionToVaultServerOperation: AsyncOperation {
  
  private var inputXdrEnvelope: String?
  private var inputHorizonResultCode: TransactionResultCode?
  
  private var transactionHash: String?
  
  // MARK: - Lifecycle
  
  init(transactionHash: String?) {
    super.init()
    self.transactionHash = transactionHash
  }
  
  override func start() {
    getDependencies()
    super.start()
  }
  
  override func main() {    
    guard let xdr = inputXdrEnvelope, let horizonResultCode = inputHorizonResultCode else {
      return
    }

    switch horizonResultCode {
    case .success:
      submitTransactionAsDone(with: xdr)
    case .badAuth:
      submitTransactionForAdditionalSigners(with: xdr)
    default:
      self.finished(error: nil)
    }
  }
}

// MARK: - Private

extension SubmitTransactionToVaultServerOperation {
  
  private func getDependencies() {
    if let dataProvider = dependencies
      .filter({ $0 is VaultServerTransactionDataBroadcast })
      .first as? VaultServerTransactionDataBroadcast {
      
      inputXdrEnvelope = dataProvider.xdrEnvelope
      inputHorizonResultCode = dataProvider.horizonResultCode
      outputError = dataProvider.error
    }
  }
  
  private func submitTransactionForAdditionalSigners(with xdr: String) {
    let apiLoader = APIRequestLoader<SubmitSignedTransactionRequest>(apiRequest: SubmitSignedTransactionRequest())
    let submitSignedTransactionRequestParameters = SubmitSignedTransactionRequestParameters(xdr: xdr)
    apiLoader.loadAPIRequest(requestData: submitSignedTransactionRequestParameters) { result in
      switch result {
      case .success(_):
        self.finished(error: nil)
      case .failure(let serverRequestError):
        self.finished(error: serverRequestError)
      }
    }
  }
  
  private func submitTransactionAsDone(with xdr: String) {
    guard let hash = transactionHash else {
      self.finished(error: nil)
      return
    }
    
    let apiLoader = APIRequestLoader<MarkTransactionAsSubmittedRequest>(apiRequest: MarkTransactionAsSubmittedRequest())
    let markTransactionAsSubmittedRequestParameters = MarkTransactionAsSubmittedRequestParameters(xdr: xdr, hash: hash)
    apiLoader.loadAPIRequest(requestData: markTransactionAsSubmittedRequestParameters) { result in
      switch result {
      case .success(_):
        self.finished(error: nil)
      case .failure(let serverRequestError):
        self.finished(error: serverRequestError)
      }
    }
  }
}
