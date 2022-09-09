class TransactionService {
  
  func submitSignedTransaction(xdr: String,
                               completion: @escaping (Result<Bool>) -> Void) {
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
  
  func markTransactionAsSubmitted(by hash: String,
                                  xdr: String,
                                  completion: @escaping (Result<Bool>) -> Void) {
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
  
  func cancelTransaction(by transactionHash: String,
                         completion: @escaping (Result<Bool>) -> Void) {
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
  
  func getPendingTransactionList(page: Int, completion: @escaping (Result<PaginationResponse<Transaction>>) -> Void) {
    let params = PendingTransactionListRequestParameters(page: String(page))
    let apiLoader = APIRequestLoader<PendingTransactionListRequest>(apiRequest: PendingTransactionListRequest())    
    apiLoader.loadAPIRequest(requestData: params) { result in
      switch result {
      case .success(let paginationResponse):
        completion(.success(paginationResponse))
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
  
  func getSignedAccounts(completion: @escaping (Result<[SignedAccount]>) -> Void) {
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
  
  func cancelOutdatedTransaction(completion: @escaping (Result<Bool>) -> Void) {
    let apiLoader = APIRequestLoader<CancelOutdatedTransactionsRequest>(apiRequest: CancelOutdatedTransactionsRequest())
    apiLoader.loadAPIRequest(requestData: nil) { result in
      switch result {
      case .success(_):
        completion(.success(true))
      case .failure(let serverRequestError):
        completion(.failure(serverRequestError))
      }
    }
  }
  
  func cancelAllTransaction(completion: @escaping (Result<Bool>) -> Void) {
    let apiLoader = APIRequestLoader<CancelAllTransactionsRequest>(apiRequest: CancelAllTransactionsRequest())
    apiLoader.loadAPIRequest(requestData: nil) { result in
      switch result {
      case .success:
        completion(.success(true))
      case .failure(let serverRequestError):
        completion(.failure(serverRequestError))
      }
    }
  }
  
  func getSequenceNumberCount(for account: String, with sequenceNumber: Int, completion: @escaping (Result<SequenceNumberCount>) -> Void) {
    let apiLoader = APIRequestLoader<SequenceNumberCountRequest>(apiRequest: SequenceNumberCountRequest())
    let params = SequenceNumberCountParameters(account: account, sequenceNumber: sequenceNumber)
    
    apiLoader.loadAPIRequest(requestData: params) { result in
      switch result {
      case .success(let sequenceNumberCount):
        completion(.success(sequenceNumberCount))
      case .failure(let serverRequestError):
        completion(.failure(serverRequestError))
      }
    }
  }

  func checkSigners(_ signers: [SignerAddress], completion: @escaping (Result<[SignerStatus]>) -> Void) {
    let checkSignersRequestData = ChecksSignersRequestData(signers: signers)
    let apiLoader = APIRequestLoader<CheckSignerRequest>(apiRequest: CheckSignerRequest())
    apiLoader.loadAPIRequest(requestData: checkSignersRequestData) { result in
      switch result {
      case .success(let statuses):
        completion(.success(statuses))
      case .failure(let serverRequestError):
        completion(.failure(serverRequestError))
      }
    }
  }
}
