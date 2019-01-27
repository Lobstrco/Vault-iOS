import Foundation

enum TransactionStatus: String {
  case success = "success"
  case failure = "failure"
}

protocol TransactionStatusPresenter {
  func transactionStatusViewDidLoad()
  func setTransactionStatus(_ status: TransactionStatus, _ isNeedToShowXDR: Bool, xdr: String?)
  
  func copyXDRButtonWasPressed(xdr: String)
  func doneButtonWasPressed()
}

protocol TransactionStatusView: class {
  func setStatusTitle(_ title: String)
  func setXdr(_ xdr: String)
  func setAnimation(with status: TransactionStatus)
}

class TransactionStatusPresenterImpl {
  
  fileprivate weak var view: TransactionStatusView?
  
  fileprivate var isNeedToShowXDR: Bool!
  fileprivate var status: TransactionStatus!
  fileprivate var xdr: String?
  
  init(view: TransactionStatusView) {
    self.view = view
  }
}

// MARK: - TransactionStatusPresenter

extension TransactionStatusPresenterImpl: TransactionStatusPresenter {
  
  func setTransactionStatus(_ status: TransactionStatus, _ isNeedToShowXDR: Bool, xdr: String?) {
    self.status = status
    self.isNeedToShowXDR = isNeedToShowXDR
    self.xdr = xdr
  }
  
  func transactionStatusViewDidLoad() {
    
    let statusTitle = status == .success ? L10n.textStatusSuccessTitle : L10n.textStatusFailureTitle
    view?.setAnimation(with: status)
    view?.setStatusTitle(statusTitle)
    
    if isNeedToShowXDR, let xdr = xdr {
      view?.setXdr(xdr)
    }
  }
  
  func copyXDRButtonWasPressed(xdr: String) {
    
  }
  
  func doneButtonWasPressed() {
    let transactionStatusViewController = view as! TransactionStatusViewController
    transactionStatusViewController.navigationController?.popToRootViewController(animated: true)
  }
}
