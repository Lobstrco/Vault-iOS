class TransactionService {
  
  func submitSignedTransaction(xdr: String, completion: @escaping (Result<Bool>) -> Void) {
    let apiLoader = APIRequestLoader<SubmitSignedTransactionRequest>(apiRequest: SubmitSignedTransactionRequest())
    let submitSignedTransactionRequestParameters = SubmitSignedTransactionRequestParameters(xdr: xdr)
    apiLoader.loadAPIRequest(requestData: submitSignedTransactionRequestParameters) { result in
      switch result {
      case .success(_):
        completion(.success(true))
      case .failure(let serverRequestError):
        completion(.failure(serverRequestError))
      }
    }
  }
  
  func markTransactionAsSubmitted(by hash: String, xdr: String, completion: @escaping (Result<Bool>) -> Void) {
    let apiLoader = APIRequestLoader<MarkTransactionAsSubmittedRequest>(apiRequest: MarkTransactionAsSubmittedRequest())
    let markTransactionAsSubmittedRequestParameters = MarkTransactionAsSubmittedRequestParameters(xdr: xdr, hash: hash)
    apiLoader.loadAPIRequest(requestData: markTransactionAsSubmittedRequestParameters) { result in
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
  
  func getNumberOfTransactions(completion: @escaping (Result<Int>) -> Void) {
    let apiLoader = APIRequestLoader<PendingTransactionListRequest>(apiRequest: PendingTransactionListRequest())
    
    apiLoader.loadAPIRequest(requestData: nil) { result in
      switch result {
      case .success(let paginationResponse):
        completion(.success(paginationResponse.count))
      case .failure(let serverRequestError):
        completion(.failure(serverRequestError))
      }
    }
  }
  
  func getSignedAccounts(completion: @escaping (Result<[SignedAccounts]>) -> Void) {
    let apiLoader = APIRequestLoader<SignedAccountsRequest>(apiRequest: SignedAccountsRequest())
    
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
