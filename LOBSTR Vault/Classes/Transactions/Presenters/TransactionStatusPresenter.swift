import Foundation
import UIKit
import stellarsdk
import StoreKit

enum TransactionStatus: String {
  case success = "success"
  case failure = "failure"
}

protocol TransactionStatusPresenter {
  init(view: TransactionStatusView,
       resultCode: TransactionResultCode,
       xdr: String)
  func transactionStatusViewDidLoad()
  func copyXDRButtonWasPressed(xdr: String)
  func doneButtonWasPressed()
  func helpButtonWasPressed()
}

protocol TransactionStatusView: class {
  func setStatusTitle(_ title: String)
  func setErrorMessage(_ message: String)
  func setXdr(_ xdr: String)
  func setAnimation(with status: TransactionStatus)
  func setFeedback(with status: TransactionStatus)
}

class TransactionStatusPresenterImpl {
  
  private var view: TransactionStatusView
  private var resultCode: TransactionResultCode
  private var xdr: String
  private var transactionStatus: TransactionStatus = .failure
  
  required init(view: TransactionStatusView,
       resultCode: TransactionResultCode,
       xdr: String) {
    self.view = view
    self.resultCode = resultCode
    self.xdr = xdr
  }
}

// MARK: - TransactionStatusPresenter

extension TransactionStatusPresenterImpl: TransactionStatusPresenter {
  
  func transactionStatusViewDidLoad() {
    displayErrorMessage()
    
    transactionStatus = getTransactionStatus(by: resultCode)
    
    let statusTitle = transactionStatus == .success ? L10n.textStatusSuccessTitle : L10n.textStatusFailureTitle
    view.setAnimation(with: transactionStatus)
    view.setStatusTitle(statusTitle)
    view.setFeedback(with: transactionStatus)
    
    if resultCode == .badAuth {
      view.setXdr(xdr)
    }
  }
  
  func copyXDRButtonWasPressed(xdr: String) {
    UIPasteboard.general.string = xdr
  }
  
  func doneButtonWasPressed() {
    let transactionStatusViewController = view as! TransactionStatusViewController
    transactionStatusViewController.navigationController?.popToRootViewController(animated: true)
    requestReview()
  }
  
  func helpButtonWasPressed() {
    let helpViewController = HelpViewController.createFromStoryboard()
    
    let transactionStatusViewController = view as! TransactionStatusViewController
    transactionStatusViewController.navigationController?.pushViewController(helpViewController, animated: true)
  }
}

// MARK: - Private

extension TransactionStatusPresenterImpl {
  
  private func getTransactionStatus(by resultCode: TransactionResultCode) -> TransactionStatus {
    switch resultCode {
    case .success, .badAuth:
      return .success
    default:
      return .failure
    }
  }
  
  private func displayErrorMessage() {
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
  
  private func requestReview() {
    if transactionStatus == .success {
      SKStoreReviewController.requestReview()
    }
  }
}
