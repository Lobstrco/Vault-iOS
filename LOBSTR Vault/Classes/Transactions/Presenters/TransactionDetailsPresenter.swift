import Foundation
import stellarsdk

protocol TransactionDetailsPresenter {
  var numberOfOperation: Int { get }
  func setTransactionData(_ transaction: Transaction)
  func transactionDetailsViewDidLoad()
  func operationWasSelected(by index: Int)
  func confirmButtonWasPressed()
  func denyButtonWasPressed()
  func denyOperationWasConfirmed()
  func configure(_ cell: OperationTableViewCell, forRow row: Int)
}

protocol TransactionDetailsView: class {
  func setOperationList()
  func setConfirmationAlert()
  func setErrorAlert(for error: Error)
}

class TransactionDetailsPresenterImpl {
  
  fileprivate weak var view: TransactionDetailsView?
  fileprivate weak var crashlyticsService: CrashlyticsService?
  fileprivate var transaction: Transaction?
  
  fileprivate var operationNames: [String] = []
  
  var numberOfOperation: Int {
    return operationNames.count
  }
  
  // MARK: - Init

  init(view: TransactionDetailsView, crashlyticsService: CrashlyticsService = CrashlyticsService()) {
    self.view = view
    self.crashlyticsService = crashlyticsService
  }
  
  // MARK: - Public
  
  func setOperationList() {
    guard let transaction = transaction else { return }
    guard let xdr = transaction.xdr else { return }
    
    do {
      operationNames = try TransactionHelper.getListOfOperationNames(from: xdr)
    } catch {
      crashlyticsService?.recordCustomException(error)
      view?.setErrorAlert(for: error)
      return
    }
    
    view?.setOperationList()
  }
  
  func transitionToTransactionListScreen() {
    let transactionDetailsViewController = view as! TransactionDetailsViewController
    transactionDetailsViewController.navigationController?.popToRootViewController(animated: true)
  }
  
  func transitionToTransactionStatus() {
    let transactionStatusViewController = TransactionStatusViewController.createFromStoryboard()

    let transactionDetailsViewController = view as! TransactionDetailsViewController
    transactionDetailsViewController.navigationController?.pushViewController(transactionStatusViewController, animated: true)
  }
  
  func transition(to operation: stellarsdk.Operation) {
    let operationViewController = OperationViewController.createFromStoryboard()
    
    operationViewController.presenter = OperationPresenterImpl(view: operationViewController)
    operationViewController.presenter.setOperation(operation)

    let transactionDetailsViewController = view as! TransactionDetailsViewController
    transactionDetailsViewController.navigationController?.pushViewController(operationViewController, animated: true)
  }
}

// MARK: - TransactionDetailsPresenter

extension TransactionDetailsPresenterImpl: TransactionDetailsPresenter {
  
  func transactionDetailsViewDidLoad() {
    setOperationList()
  }
  
  func setTransactionData(_ transaction: Transaction) {
    self.transaction = transaction
  }
  
  func operationWasSelected(by index: Int) {
    guard let xdr = transaction?.xdr else { return }
    
    do {
      let operation = try TransactionHelper.getOperation(from: xdr, by: index)
      transition(to: operation)
    } catch {
      crashlyticsService?.recordCustomException(error)
      view?.setErrorAlert(for: error)
    }
  }
  
  func confirmButtonWasPressed() {
    transitionToTransactionStatus()
  }
  
  func denyButtonWasPressed() {
    view?.setConfirmationAlert()
  }
  
  func denyOperationWasConfirmed() {
    transitionToTransactionListScreen()
  }
  
  func configure(_ cell: OperationTableViewCell, forRow row: Int) {
    cell.setOperationTitle(operationNames[row])
  }
}
