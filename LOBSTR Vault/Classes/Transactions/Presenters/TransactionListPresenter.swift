import Foundation
import stellarsdk

protocol TransactionListView: class {
  func setTransactionList(isEmpty: Bool)
  func reloadTransactionList(isEmpty: Bool)
  func setProgressAnimation()
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
  func set(date: String?, operationType: String?)
}

class TransactionListPresenterImpl {
  
  fileprivate weak var view: TransactionListView?
  fileprivate var transactionList: [Transaction] = []
  fileprivate let crashlyticsService: CrashlyticsService
  fileprivate let transactionService: TransactionService
  fileprivate var mnemonicManager: MnemonicManager
  
  var importXDRInput: ImportXDRInput?
  
  init(view: TransactionListView,
       crashlyticsService: CrashlyticsService = CrashlyticsService(),
       transactionService: TransactionService = TransactionService(),
       mnemonicManager: MnemonicManager = MnemonicManagerImpl()) {
    
    self.view = view
    self.crashlyticsService = crashlyticsService
    self.transactionService = transactionService
    self.mnemonicManager = mnemonicManager
    
    NotificationCenter.default.addObserver(self, selector: #selector(onDidRemoveTransaction(_:)), name: .didRemoveTransaction, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onDidChangeTransactionList(_:)), name: .didChangeTransactionList, object: nil)
  }
  
  @objc func onDidChangeTransactionList(_ notification: Notification) {
    view?.setProgressAnimation()
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
  
  private func getOperationType(from operationNames: [String]) -> String {
    guard !operationNames.isEmpty else { return "none" }
    let operationType = operationNames.count == 1 ? operationNames.first! : "\(operationNames.count) operations"
    
    return operationType
  }
  
  private func displayPendingTransactions(isFirstTime: Bool = false) {
    transactionService.getPendingTransactionList() { result in
      switch result {
      case .success(let transactions):
        self.transactionList = transactions
        if isFirstTime {
          self.view?.setTransactionList(isEmpty: self.transactionList.isEmpty)
        } else {
          self.view?.reloadTransactionList(isEmpty: self.transactionList.isEmpty)
        }
      case .failure(let error):
        self.crashlyticsService.recordCustomException(error)
        self.view?.setErrorAlert(for: error)
      }
    }
  }
  
  private func submitTransaction(with transactionEnvelope: String) {
    StellarSDK(withHorizonUrl: Constants.horizonURL).transactions.postTransaction(transactionEnvelope: transactionEnvelope) { (response) -> (Void) in
      switch response {
      case .success(_):
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
          self.submitTransactionToVaultServer(transactionEnvelope)
        }
      case .failure(let error):
        self.resolveTransactionRequest(error, in: transactionEnvelope)
      }
    }
  }
  
  private func resolveTransactionRequest(_ error: HorizonRequestError, in transactionEnvelope: String) {
    switch error {
    case .badRequest(let message, _):
      let resultCode = try! TransactionHelper.getTransactionResultCode(from: message)
      switch resultCode {
      case .badAuth:
        self.submitTransactionToVaultServer(transactionEnvelope, isNeedAdditionalSignature: true)
      default:
        DispatchQueue.main.async {
          self.transitionToTransactionStatus(.failure, resultCode: resultCode)
          self.importXDRInput?.setProgressAnimation(isEnable: false)
          self.importXDRInput?.closePopup()
        }
      }
    default:
      self.importXDRInput?.setProgressAnimation(isEnable: false)
      self.view?.setErrorAlert(for: error)
    }
  }
  
  private func submitTransactionToVaultServer(_ transactionEnvelope: String, isNeedAdditionalSignature: Bool = false) {
    transactionService.submitSignedTransaction(xdr: transactionEnvelope,
                                               isNeedAdditionalSignature: isNeedAdditionalSignature) { result in
      switch result {
      case .success(_):
        DispatchQueue.main.async {
          let resultCode: TransactionResultCode = isNeedAdditionalSignature ? .badAuth : .success
          let xdr: String? = isNeedAdditionalSignature ? transactionEnvelope : nil
          
          self.transitionToTransactionStatus(.success, resultCode: resultCode, xdr: xdr)
          self.importXDRInput?.setProgressAnimation(isEnable: false)
          self.importXDRInput?.closePopup()
        }
      case .failure(let error):
        self.view?.setErrorAlert(for: error)
        self.importXDRInput?.setProgressAnimation(isEnable: false)
      }
    }
  }
}

// MARK: - ImportXDROutput

extension TransactionListPresenterImpl: ImportXDROutput {
  
  private func displayImportXDRPopover() {
    let importXDRView = Bundle.main.loadNibNamed("ImportXDR", owner: view, options: nil)?.first as! ImportXDR
    let popoverHeight: CGFloat = 550
    let popover = CustomPopoverViewController(height: popoverHeight, view: importXDRView)
    
    importXDRView.popoverDelegate = popover
    importXDRView.output = self
    importXDRInput = importXDRView
    
    view?.setImportXDRPopover(popover)
  }
  
  func submitXDR(_ xdr: String) {
    guard let transactionEnvelopeXDR = try? TransactionEnvelopeXDR(xdr: xdr) else {
      importXDRInput?.setError(error: "Invalid XDR")
      return
    }
    
    importXDRInput?.setProgressAnimation(isEnable: true)
    
    TransactionHelper.signTransaction(transactionEnvelopeXDR: transactionEnvelopeXDR,
                                      mnemonicManager: mnemonicManager) { result in
      switch result {
      case .success(let transactionEnvelope):
        self.submitTransaction(with: transactionEnvelope)
      case .failure(let error):
        self.importXDRInput?.setProgressAnimation(isEnable: false)
        self.view?.setErrorAlert(for: error)
      }
    }
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
    view?.setProgressAnimation()
    displayPendingTransactions(isFirstTime: true)
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
  
  func pullToRefreshWasActivated() {
    displayPendingTransactions()
  }
}

// MARK: - Transitions

extension TransactionListPresenterImpl {
  private func transitionToTransactionDetailsScreen(by index: Int) {
    let transactionDetailsViewController = TransactionDetailsViewController.createFromStoryboard()
    
    transactionDetailsViewController.presenter = TransactionDetailsPresenterImpl(view: transactionDetailsViewController)
    transactionDetailsViewController.presenter.setTransactionData(transactionList[index], withIndex: index)
    
    let transactionListViewController = view as! TransactionListViewController
    transactionListViewController.navigationController?.pushViewController(transactionDetailsViewController, animated: true)
  }
  
  func transitionToTransactionStatus(_ status: TransactionStatus, resultCode: TransactionResultCode, xdr: String? = nil) {
    let transactionStatusViewController = TransactionStatusViewController.createFromStoryboard()
    
    transactionStatusViewController.presenter = TransactionStatusPresenterImpl(view: transactionStatusViewController,
                                                                               with: status,
                                                                               resultCode: resultCode,
                                                                               xdr: xdr)
    
    let transactionListViewController = view as! TransactionListViewController
    transactionListViewController.navigationController?.pushViewController(transactionStatusViewController, animated: true)
  }
}
