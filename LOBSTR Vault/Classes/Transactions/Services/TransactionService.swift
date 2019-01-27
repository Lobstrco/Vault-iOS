class TransactionService {
  
  func submitSignedTransaction(xdr: String, isNeedAdditionalSignature: Bool, completion: @escaping (Result<Bool>) -> Void) {
    let apiLoader = APIRequestLoader<SubmitSignedTransactionRequest>(apiRequest: SubmitSignedTransactionRequest())
    let submit = isNeedAdditionalSignature ? nil : true
    let submitSignedTransactionRequestParameters = SubmitSignedTransactionRequestParameters(submit: submit, xdr: xdr)
    apiLoader.loadAPIRequest(requestData: submitSignedTransactionRequestParameters) { result in
      switch result {
      case .success(_):
        completion(.success(true))
      case .failure(let serverRequestError):
        completion(.failure(serverRequestError))
      }
    }
  }
  
  func cancelTransaction(by transactionHash: String, completion: @escaping (Result<Bool>) -> Void) {
    let apiLoader = APIRequestLoader<CancelTransactionRequest>(apiRequest: CancelTransactionRequest())
    let cancelTransactionRequestParameters = CancelTransactionRequestParameters(hash: transactionHash)
    apiLoader.loadAPIRequest(requestData: cancelTransactionRequestParameters) { result in
      switch result {
      case .success(_):
        completion(.success(true))
      case .failure(let serverRequestError):
        completion(.failure(serverRequestError))
      }
    }
  }
  
  func getPendingTransactionList(completion: @escaping (Result<[Transaction]>) -> Void) {
    let apiLoader = APIRequestLoader<PendingTransactionListRequest>(apiRequest: PendingTransactionListRequest())    
    apiLoader.loadAPIRequest(requestData: nil) { result in
      switch result {
      case .success(let paginationResponse):
        completion(.success(paginationResponse.results))
      case .failure(let serverRequestError):
        completion(.failure(serverRequestError))
      }
    }
  }
}