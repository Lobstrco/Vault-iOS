import Foundation
import stellarsdk

enum TaskStatus {
  case ready
  case loading
  case failure
}

protocol TransactionListView: class {
  func setTransactionList(isEmpty: Bool, isThereMoreContent: Bool)
  func reloadTransactionList(isEmpty: Bool, isThereMoreContent: Bool)
  func setProgressAnimation(isEnabled: Bool)
  func setErrorAlert(for error: Error)
  func setImportXDRPopover(_ popover: CustomPopoverViewController)
  func deleteRow(by index: Int, isEmpty: Bool)
  func setHUDSuccessViewAfterRemoveOperation()
  func setFirstLoadingStatus(_ status: Bool)
}

protocol TransactionListPresenter {
  var countOfTransactions: Int { get }
  func configure(_ cell: TransactionListCellView, forRow row: Int)
  func transactionWasSelected(with index: Int)
  func transactionListViewDidLoad()
  func importXDRButtonWasPressed()
  func clearButtonWasPressed()
  func pullToRefreshWasActivated()
  func tableViewReachedBottom()
}

protocol TransactionListCellView {
  func set(date: String?, operationType: String?, sourceAccount: String, isValid: Bool)
}

class TransactionListPresenterImpl {
  private weak var view: TransactionListView?
  private var transactionList: [Transaction] = []
  private let crashlyticsService: CrashlyticsService
  private let transactionService: TransactionService
  private var transactionListStatus: TaskStatus = .ready
  
  private var pageNumber = 1
  
  init(view: TransactionListView,
       crashlyticsService: CrashlyticsService = CrashlyticsService(),
       transactionService: TransactionService = TransactionService()) {
    self.view = view
    self.crashlyticsService = crashlyticsService
    self.transactionService = transactionService
    
    addObservers()
  }
  
  @objc func onDidChangeTransactionList(_ notification: Notification) {
    displayPendingTransactions(isFirstTime: false, withClearingData: true)
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
                                           name: .didChangeSignerDetails,
                                           object: nil)
    
//    NotificationCenter.default.addObserver(self,
//                                           selector: #selector(onDidChangeTransactionList(_:)),
//                                           name: UIApplication.didBecomeActiveNotification,
//                                           object: nil)
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
  
  private func displayPendingTransactions(isFirstTime: Bool = false, withClearingData: Bool = false) {
    guard transactionListStatus == .ready else {
      return
    }
    
    guard ConnectionHelper.isConnectedToNetwork() else {
      return
    }
    
    setStatus(.loading)
    
    if withClearingData {
      pageNumber = 1
    }
    
    transactionService.getPendingTransactionList(page: pageNumber) { result in
      switch result {
      case .success(let response):
        var isThereMoreContent = false
        if response.hasNextPage() {
          self.pageNumber += 1
          isThereMoreContent = true
        }
        
        if withClearingData {
          self.transactionList = response.results
        } else {
          self.transactionList.append(contentsOf: response.results)
        }
        
        if isFirstTime {
          self.view?.setTransactionList(isEmpty: self.transactionList.isEmpty,
                                        isThereMoreContent: isThereMoreContent)
        } else {
          self.view?.reloadTransactionList(isEmpty: self.transactionList.isEmpty,
                                           isThereMoreContent: isThereMoreContent)
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

// MARK: - TransactionImportDelegate

extension TransactionListPresenterImpl: TransactionImportDelegate {
  func submitTransaction(with xdr: String) {
    var transaction = Transaction()
    transaction.xdr = xdr
    transitionToTransactionDetailsScreenFromImport(transaction: transaction)
  }
}

// MARK: - TransactionListPresenter

extension TransactionListPresenterImpl: TransactionListPresenter {
  var countOfTransactions: Int {
    return transactionList.count
  }
  
  func tableViewReachedBottom() {
    displayPendingTransactions()
  }
  
  func importXDRButtonWasPressed() {
    transitionToTransactionImport()
  }
  
  func clearButtonWasPressed() {
    transactionService.cancelOutdatedTransaction { result in
      switch result {
      case .success:
        NotificationCenter.default.post(name: .didChangeTransactionList, object: nil)
      case .failure(let error):
        self.view?.setErrorAlert(for: error)
      }
    }
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
    var sourceAccount = "undefined"
    
    var operationNames: [String] = []
    do {
      guard let transactionXDR = try? TransactionXDR(xdr: xdr) else {
        throw VaultError.TransactionError.invalidTransaction
      }
      
      operationNames = try TransactionHelper.getListOfOperationNames(from: transactionXDR)
      sourceAccount = transactionXDR.sourceAccount.accountId
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
    cell.set(date: operationDate,
             operationType: operationType,
             sourceAccount: sourceAccount,
             isValid: isValid)
  }
  
  func transactionWasSelected(with index: Int) {
    transitionToTransactionDetailsScreenFromList(by: index)
  }
  
  func pullToRefreshWasActivated() {
    displayPendingTransactions(isFirstTime: false, withClearingData: true)
  }
}

// MARK: - Transitions

extension TransactionListPresenterImpl {
  private func transitionToTransactionImport() {
    let transactionImportViewController = TransactionImportViewController.createFromStoryboard()
    transactionImportViewController.delegate = self
    
    let transactionListViewController = view as! TransactionListViewController
    transactionListViewController.navigationController?.present(transactionImportViewController, animated: true, completion: nil)
  }
  
  private func transitionToTransactionDetailsScreenFromList(by index: Int) {
    let transactionDetailsViewController = TransactionDetailsViewController.createFromStoryboard()
    
    transactionDetailsViewController.presenter =
      TransactionDetailsPresenterImpl(view: transactionDetailsViewController,
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
