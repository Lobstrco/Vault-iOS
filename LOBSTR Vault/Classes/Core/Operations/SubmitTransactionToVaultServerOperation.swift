import Foundation
import stellarsdk

class SubmitTransactionToVaultServerOperation: AsyncOperation {
  
  private var inputXdrEnvelope: String?
  private var inputHorizonResult: (resultCode: TransactionResultCode, operaiotnMessageError: String?)?
  private var inputTransactionHash: String?
  
  // MARK: - Lifecycle
  
  override func start() {
    getDependencies()
    super.start()
  }
  
  override func main() {
    guard let xdr = inputXdrEnvelope, let horizonResultCode = inputHorizonResult?.resultCode else {
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
      inputHorizonResult = dataProvider.horizonResult
      inputTransactionHash = dataProvider.transactionHash
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
    guard let hash = inputTransactionHash else {
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
