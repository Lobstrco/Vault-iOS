import Foundation
import stellarsdk

protocol TransactionDetailsPresenter {
  func setTransactionData(_ transaction: Transaction)
  func transactionDetailsViewDidLoad()
  func operationWasSelected(by index: Int)
  func confirmButtonWasPressed()
  func denyButtonWasPressed()
  func denyOperationWasConfirmed()
}

protocol TransactionDetailsView: class {
  func setOperationList()
  func setConfirmationAlert()
}

class TransactionDetailsPresenterImpl: TransactionDetailsPresenter {
  
  fileprivate weak var view: TransactionDetailsView?
  fileprivate var transaction: Transaction?
  
  var operationNames: [String] = []
  var operationNumber = 0
  
  func initData(view: TransactionDetailsView) {
    self.view = view
  }
  
  // MARK: - TransactionDetailsPresenter
  
  func transactionDetailsViewDidLoad() {
    guard let transaction = transaction else { return }
    
    if let xdr = transaction.xdr {
      operationNames = TransactionHelper.getListOfOperationNames(from: xdr)
      operationNumber = operationNames.count
      view?.setOperationList()
    }
  }
  
  func setTransactionData(_ transaction: Transaction) {
    self.transaction = transaction
  }
  
  func operationWasSelected(by index: Int) {
    transitionToOperationDetailsScreen(by: index)
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
  
  // MARK: - Public
  
  func transitionToTransactionListScreen() {
    let transactionDetailsViewController = view as! TransactionDetailsViewController
    transactionDetailsViewController.navigationController?.popToRootViewController(animated: true)
  }
  
  func transitionToTransactionStatus() {
    guard let vc = TransactionStatusViewController.createFromStoryboard() else { fatalError() }
    
    let transactionDetailsViewController = view as! TransactionDetailsViewController
    transactionDetailsViewController.navigationController?.pushViewController(vc, animated: true)
  }
  
  func transitionToOperationDetailsScreen(by index: Int) {
    guard let xdr = transaction?.xdr else { return }
    
    let operation = TransactionHelper.getOperation(from: xdr, by: index)
    guard let vc = OperationViewController.createFromStoryboard() else { fatalError() }
    vc.presenter.setOperation(operation)
    
    let transactionDetailsViewController = view as! TransactionDetailsViewController
    transactionDetailsViewController.navigationController?.pushViewController(vc, animated: true)
  }
}
