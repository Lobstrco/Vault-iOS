import Foundation
import stellarsdk

enum TaskStatus {
  case ready
  case loading
  case failure
}

protocol TransactionListView: class {
  func setTransactionList(isEmpty: Bool)
  func reloadTransactionList(isEmpty: Bool)
  func setProgressAnimation(isEnabled: Bool)
  func setErrorAlert(for error: Error)
  func setImportXDRPopover(_ popover: CustomPopoverViewController)
  func deleteRow(by index: Int, isEmpty: Bool)
  func setHUDSuccessViewAfterRemoveOperation()
}

protocol TransactionListPresenter {
  var countOfTransactions: Int { get }
  func configure(_ cell: TransactionListCellView, forRow row: Int)
  func transactionWasSelected(with index: Int)
  func transactionListViewDidLoad()
  func importXDRButtonWasPressed()
  func pullToRefreshWasActivated()
}

protocol TransactionListCellView {
  func set(date: String?, operationType: String?, isValid: Bool)
}

class TransactionListPresenterImpl {
  
  fileprivate weak var view: TransactionListView?
  fileprivate var transactionList: [Transaction] = []
  fileprivate let crashlyticsService: CrashlyticsService
  fileprivate let transactionService: TransactionService
  fileprivate var importXDRInput: ImportXDRInput?
  fileprivate var transactionListStatus: TaskStatus = .ready
  
  init(view: TransactionListView,
       crashlyticsService: CrashlyticsService = CrashlyticsService(),
       transactionService: TransactionService = TransactionService()) {
    
    self.view = view
    self.crashlyticsService = crashlyticsService
    self.transactionService = transactionService
    
    addObservers()
  }
  
  @objc func onDidChangeTransactionList(_ notification: Notification) {
    displayPendingTransactions()
  }
  
  @objc func onDidRemoveTransaction(_ notification: Notification) {
    guard let transactionIndex = notification.userInfo?["transactionIndex"] as? Int else { return }
    transactionList.remove(at: transactionIndex)
    let delayBeforeTableRowWillBeDeleted = 1.2
    DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforeTableRowWillBeDeleted) {
      self.view?.deleteRow(by: transactionIndex, isEmpty: self.transactionList.isEmpty)
      self.view?.setHUDSuccessViewAfterRemoveOperation()
    }
  }
  
  // MARK: - Private
  
  private func addObservers() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidRemoveTransaction(_:)),
                                           name: .didRemoveTransaction,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidChangeTransactionList(_:)),
                                           name: .didChangeTransactionList,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidChangeTransactionList(_:)),
                                           name: UIApplication.didBecomeActiveNotification,
                                           object: nil)
  }
  
  private func setStatus(_ status: TaskStatus) {
    transactionListStatus = status
    
    if status == .loading {
      view?.setProgressAnimation(isEnabled: true)
    } else {
      view?.setProgressAnimation(isEnabled: false)
    }
  }
  
  private func getOperationType(from operationNames: [String]) -> String {
    guard !operationNames.isEmpty else { return "none" }
    let operationType = operationNames.count == 1 ? operationNames.first! : "\(operationNames.count) operations"
    
    return operationType
  }
  
  private func displayPendingTransactions(isFirstTime: Bool = false) {
    guard transactionListStatus == .ready else {      
      return
    }
    
    guard ConnectionHelper.isConnectedToNetwork() else {
      return
    }
    
    setStatus(.loading)
    
    transactionService.getPendingTransactionList() { result in
      switch result {
      case .success(let transactions):
        self.transactionList = transactions
        if isFirstTime {
          self.view?.setTransactionList(isEmpty: self.transactionList.isEmpty)
        } else {
          self.view?.reloadTransactionList(isEmpty: self.transactionList.isEmpty)
        }
        self.setStatus(.ready)
      case .failure(let error):
        self.setStatus(.ready)
        self.crashlyticsService.recordCustomException(error)
        self.view?.setErrorAlert(for: error)
      }
    }
  }
}

// MARK: - ImportXDROutput

extension TransactionListPresenterImpl: ImportXDROutput {
  
  private func displayImportXDRPopover() {
    guard ConnectionHelper.isConnectedToNetwork() else {
      return
    }
    
    let importXDRView = Bundle.main.loadNibNamed("ImportXDR", owner: view, options: nil)?.first as! ImportXDR
    let popoverHeight: CGFloat = 500
    let popover = CustomPopoverViewController(height: popoverHeight, view: importXDRView)
    
    importXDRView.popoverDelegate = popover
    importXDRView.output = self
    importXDRInput = importXDRView
    
    view?.setImportXDRPopover(popover)
  }
  
  func submitTransaction(with xdr: String) {
    guard let _ = try? TransactionEnvelopeXDR(xdr: xdr) else {
      importXDRInput?.setError(error: "Invalid XDR")
      return
    }
    
    importXDRInput?.closePopup()
    
    var transaction = Transaction()
    transaction.xdr = xdr
    
    transitionToTransactionDetailsScreenFromImport(transaction: transaction)
  }
}

// MARK: - TransactionListPresenter

extension TransactionListPresenterImpl: TransactionListPresenter{
  
  var countOfTransactions: Int {
    return transactionList.count
  }
  
  func importXDRButtonWasPressed() {
    displayImportXDRPopover()
  }
  
  func transactionListViewDidLoad() {
    
    guard let viewController = view as? UIViewController else {
      return
    }
    
    if ConnectionHelper.checkConnection(viewController) {
      displayPendingTransactions(isFirstTime: true)
    }
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
    
    let isValid = transactionList[row].sequenceOutdatedAt == nil ? true : false    
    cell.set(date: operationDate, operationType: operationType, isValid: isValid)
  }
  
  func transactionWasSelected(with index: Int) {
    transitionToTransactionDetailsScreenFromList(by: index)
  }
  
  func pullToRefreshWasActivated() {
    displayPendingTransactions()
  }
}

// MARK: - Transitions

extension TransactionListPresenterImpl {
  private func transitionToTransactionDetailsScreenFromList(by index: Int) {
    let transactionDetailsViewController = TransactionDetailsViewController.createFromStoryboard()
    
    transactionDetailsViewController.presenter = TransactionDetailsPresenterImpl(view: transactionDetailsViewController,
                                                                                 transaction: transactionList[index],
                                                                                 type: .standard)
    transactionDetailsViewController.presenter.transactionListIndex = index
    
    let transactionListViewController = view as! TransactionListViewController
    transactionListViewController.navigationController?.pushViewController(transactionDetailsViewController, animated: true)
  }
  
  private func transitionToTransactionDetailsScreenFromImport(transaction: Transaction) {
    let transactionDetailsViewController = TransactionDetailsViewController.createFromStoryboard()
    
    transactionDetailsViewController.presenter = TransactionDetailsPresenterImpl(view: transactionDetailsViewController,
                                                                                 transaction: transaction,
                                                                                 type: .imported)
    let transactionListViewController = view as! TransactionListViewController
    transactionListViewController.navigationController?.pushViewController(transactionDetailsViewController, animated: true)
  }
  
  func transitionToTransactionStatus(with resultCode: TransactionResultCode, xdr: String) {
    let transactionStatusViewController = TransactionStatusViewController.createFromStoryboard()
    
    transactionStatusViewController.presenter = TransactionStatusPresenterImpl(view: transactionStatusViewController,
                                                                               resultCode: resultCode,
                                                                               xdr: xdr)
    
    let transactionListViewController = view as! TransactionListViewController
    transactionListViewController.navigationController?.pushViewController(transactionStatusViewController, animated: true)
  }
  
}
