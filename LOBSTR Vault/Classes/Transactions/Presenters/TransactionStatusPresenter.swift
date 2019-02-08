import Foundation
import UIKit
import stellarsdk

enum TransactionStatus: String {
  case success = "success"
  case failure = "failure"
}

protocol TransactionStatusPresenter {
  init(view: TransactionStatusView,
       with status: TransactionStatus,
       resultCode: TransactionResultCode,
       xdr: String?)
  func transactionStatusViewDidLoad()
  func copyXDRButtonWasPressed(xdr: String)
  func doneButtonWasPressed()
}

protocol TransactionStatusView: class {
  func setStatusTitle(_ title: String)
  func setErrorMessage(_ message: String)
  func setXdr(_ xdr: String)
  func setAnimation(with status: TransactionStatus)
}

class TransactionStatusPresenterImpl {
  
  fileprivate var view: TransactionStatusView
  fileprivate var status: TransactionStatus
  fileprivate var resultCode: TransactionResultCode
  fileprivate var xdr: String?
  
  required init(view: TransactionStatusView,
       with status: TransactionStatus,
       resultCode: TransactionResultCode,
       xdr: String?) {
    self.view = view
    self.status = status
    self.resultCode = resultCode
    self.xdr = xdr
  }
}

// MARK: - TransactionStatusPresenter

extension TransactionStatusPresenterImpl: TransactionStatusPresenter {
  
  func transactionStatusViewDidLoad() {
    displayErrorMessage()
    let statusTitle = status == .success ? L10n.textStatusSuccessTitle : L10n.textStatusFailureTitle
    view.setAnimation(with: status)
    view.setStatusTitle(statusTitle)
    
    if let xdr = xdr {
      view.setXdr(xdr)
    }
  }
  
  func copyXDRButtonWasPressed(xdr: String) {
    UIPasteboard.general.string = xdr
  }
  
  func doneButtonWasPressed() {
    let transactionStatusViewController = view as! TransactionStatusViewController
    transactionStatusViewController.navigationController?.popToRootViewController(animated: true)
  }
  
  func displayErrorMessage() {
    let errorMessage = getErrorMessage(from: resultCode)
    view.setErrorMessage(errorMessage)
  }
  
  private func getErrorMessage(from resultCode: TransactionResultCode) -> String {
    switch resultCode {
    case .success:
      return ""
    case .badAuth:
      return "You need more signatures"
    case .badSeq:
      return "Sequence number does not match source account"
    default:
      return "Transaction was failed"
    }
  }
}
