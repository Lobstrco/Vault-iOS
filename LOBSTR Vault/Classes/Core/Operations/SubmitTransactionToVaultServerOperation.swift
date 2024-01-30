import Foundation
import stellarsdk

class SubmitTransactionToVaultServerOperation: AsyncOperation {
  
  private var inputXdrEnvelope: String?
  private var inputHorizonResult: (resultCode: TransactionResultCode, operationMessageError: String?)?
  private var inputTransactionHash: String?
  
  private var transactionType: ServerTransactionType
  
  // MARK: - Lifecycle
  
  override func start() {
    getDependencies()
    super.start()
  }
  
  init(transactionType: ServerTransactionType) {
    self.transactionType = transactionType
    super.init()
  }
  
  override func main() {
    Logger.operations.debug("SubmitTransactionToVaultServerOperation start")
    guard let xdr = inputXdrEnvelope else {
      return
    }
    
    guard transactionType == .transaction else {
      submitTransactionForAdditionalSigners(with: xdr)
      finished(error: nil)
      return
    }
    
    guard let horizonResultCode = inputHorizonResult?.resultCode else {
      finished(error: VaultError.OperationError.invalidOperation)
      return
    }

    switch horizonResultCode {
    case .success:
      submitTransactionAsDone(with: xdr)
    case .badAuth:
      submitTransactionForAdditionalSigners(with: xdr)
    default:
      finished(error: nil)
    }
  }
}

// MARK: - Private

extension SubmitTransactionToVaultServerOperation {
  
  private func getDependencies() {
    switch transactionType {
    case .authChallenge:
      if let dataProvider = dependencies
        .filter({ $0 is HorizonTransactionDataBroadcast })
        .first as? HorizonTransactionDataBroadcast {
        
        inputXdrEnvelope = dataProvider.xdrEnvelope
        outputError = dataProvider.error
      }
    case .transaction:
      if let dataProvider = dependencies
        .filter({ $0 is VaultServerTransactionDataBroadcast })
        .first as? VaultServerTransactionDataBroadcast {
        
        inputXdrEnvelope = dataProvider.xdrEnvelope
        inputHorizonResult = dataProvider.horizonResult
        inputTransactionHash = dataProvider.transactionHash
        outputError = dataProvider.error
      }
    default: break
    }
  }
  
  private func submitTransactionForAdditionalSigners(with xdr: String) {
    let apiLoader = APIRequestLoader<SubmitSignedTransactionRequest>(apiRequest: SubmitSignedTransactionRequest())
    let submitSignedTransactionRequestParameters = SubmitSignedTransactionRequestParameters(xdr: xdr)
    apiLoader.loadAPIRequest(requestData: submitSignedTransactionRequestParameters) { result in
      switch result {
      case .success(_):
        Logger.operations.debug("SubmitTransactionToVaultServerOperation success but need more signatures")
        self.finished(error: nil)
      case .failure(let serverRequestError):
        Logger.operations.debug("SubmitTransactionToVaultServerOperation failure")
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
        Logger.operations.debug("SubmitTransactionToVaultServerOperation success")
        self.finished(error: nil)
      case .failure(let serverRequestError):
        Logger.operations.debug("SubmitTransactionToVaultServerOperation failure")
        self.finished(error: serverRequestError)
      }
    }
  }
}
