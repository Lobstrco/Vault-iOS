import Foundation

protocol TransactionListView: class {
  func displayTransactionList()
}

protocol TransactionListPresenter {
  var countOfTransactions: Int { get }
  func configure(cell: TransactionListCellView, forRow row: Int)
  func transactionWasSelected(with index: Int)
  func transactionListViewDidLoad()
}

protocol TransactionListCellView {
  func display(date: String?, operationType: String?)
}

class TransactionListPresenterImpl: TransactionListPresenter {
  
  fileprivate weak var view: TransactionListView?
  fileprivate var transactionList: [Transaction] = []
  
  var countOfTransactions: Int {
    get { return transactionList.count }
  }
  
  init(view: TransactionListView) {
    self.view = view    
  }
  
  // MARK: - TransactionListPresenter
  
  func transactionListViewDidLoad() {
    getPendingTransactions()
  }
  
  func configure(cell: TransactionListCellView, forRow row: Int) {
    guard let xdr = transactionList[row].xdr else { return }
    
    let operationNames = TransactionHelper.getListOfOperationNames(from: xdr)
    let operationType = getOperationType(from: operationNames)
    
    var operationDate: String = "invalid date"
    if let transactionDate = transactionList[row].addedAt {
      operationDate = TransactionHelper.getValidatedDate(from: transactionDate)
    }
    
    cell.display(date: operationDate, operationType: operationType)
  }
  
  func transactionWasSelected(with index: Int) {
    transitionToTransactionDetailsScreen(by: index)
  }
  
  // MARK: - Public Methods
  
  func getOperationType(from operationNames: [String]) -> String {
    guard !operationNames.isEmpty else { return "none" }
    
    var operationType = ""
    
    operationType = operationNames.count == 1 ? operationNames.first! : "\(operationNames.count) Operations"
    
    return operationType
  }
  
  func getPendingTransactions() {
    let apiLoader = APIRequestLoader<PendingTransactionListRequest>(apiRequest: PendingTransactionListRequest())    
    
    apiLoader.loadAPIRequest(requestData: nil) { result in
      switch result {
      case .success(let paginationResponse):
        self.transactionList = paginationResponse.results
        self.view?.displayTransactionList()
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
    guard let vc = TransactionDetailsViewController.createFromStoryboard() else { fatalError() }
    vc.presenter.setTransactionData(transactionList[index])
    
    let transactionListViewController = view as! TransactionListViewController
    transactionListViewController.navigationController?.pushViewController(vc, animated: true)
  }
}
