import Foundation

protocol TransactionListView: class {
  func setTransactionList()
  func setErrorAlert(for error: Error)
}

protocol TransactionListPresenter {
  var countOfTransactions: Int { get }
  func configure(_ cell: TransactionListCellView, forRow row: Int)
  func transactionWasSelected(with index: Int)
  func transactionListViewDidLoad()
}

protocol TransactionListCellView {
  func set(date: String?, operationType: String?)
}

class TransactionListPresenterImpl {
  
  fileprivate weak var view: TransactionListView?
  fileprivate var transactionList: [Transaction] = []
  let crashlyticsService: CrashlyticsService
  
  init(view: TransactionListView, crashlyticsService: CrashlyticsService = CrashlyticsService()) {
    self.view = view
    self.crashlyticsService = crashlyticsService
  }
  
  // MARK: - Public
  
  func getOperationType(from operationNames: [String]) -> String {
    guard !operationNames.isEmpty else { return "none" }
    let operationType = operationNames.count == 1 ? operationNames.first! : "\(operationNames.count) operations"
    
    return operationType
  }
  
  func getPendingTransactions() {
    let apiLoader = APIRequestLoader<PendingTransactionListRequest>(apiRequest: PendingTransactionListRequest())    
    
    apiLoader.loadAPIRequest(requestData: nil) { result in
      switch result {
      case .success(let paginationResponse):
        self.transactionList = paginationResponse.results
        self.view?.setTransactionList()
      case .failure(let serverRequestError):
        switch serverRequestError {
        case ServerRequestError.needRepeatRequest:          
          self.getPendingTransactions()
        default:
          print("Error: \(serverRequestError)")
        }
      }
    }
  }
  
  func transitionToTransactionDetailsScreen(by index: Int) {
    let transactionDetailsViewController = TransactionDetailsViewController.createFromStoryboard()
    
    transactionDetailsViewController.presenter = TransactionDetailsPresenterImpl(view: transactionDetailsViewController)
    transactionDetailsViewController.presenter.setTransactionData(transactionList[index])
    
    let transactionListViewController = view as! TransactionListViewController
    transactionListViewController.navigationController?.pushViewController(transactionDetailsViewController, animated: true)
  }
}

// MARK: - TransactionListPresenter

extension TransactionListPresenterImpl: TransactionListPresenter{
  
  var countOfTransactions: Int {
    return transactionList.count
  }
  
  func transactionListViewDidLoad() {
    getPendingTransactions()
  }
  
  func configure(_ cell: TransactionListCellView, forRow row: Int) {
    guard let xdr = transactionList[row].xdr else { return }
    
    var operationNames: [String] = []
    do {
      operationNames = try TransactionHelper.getListOfOperationNames(from: xdr)
    } catch {
      crashlyticsService.recordCustomException(error)
      view?.setErrorAlert(for: error)
      
      return
    }
    
    let operationType = getOperationType(from: operationNames)
    
    var operationDate: String = "invalid date"
    if let transactionDate = transactionList[row].addedAt {
      operationDate = TransactionHelper.getValidatedDate(from: transactionDate)
    }
    
    cell.set(date: operationDate, operationType: operationType)
  }
  
  func transactionWasSelected(with index: Int) {
    transitionToTransactionDetailsScreen(by: index)
  }
}
