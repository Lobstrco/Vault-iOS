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
       transactionResult: (TransactionResultCode, String?),
       xdr: String?, transactionType: ServerTransactionType?)
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
  private var transactionResult: (code: TransactionResultCode, operationMessageError: String?)
  private var xdr: String?
  private var transactionType: ServerTransactionType?
  private var transactionStatus: TransactionStatus = .failure
  
  required init(view: TransactionStatusView,
       transactionResult: (TransactionResultCode, String?),
       xdr: String?, transactionType: ServerTransactionType?) {
    self.view = view
    self.transactionResult = transactionResult
    self.xdr = xdr
    self.transactionType = transactionType
  }
}

// MARK: - TransactionStatusPresenter

extension TransactionStatusPresenterImpl: TransactionStatusPresenter {
  
  func transactionStatusViewDidLoad() {
    displayErrorMessage()
    
    transactionStatus = getTransactionStatus(by: transactionResult.code)
    
    let statusTitle = transactionStatus == .success ? L10n.textStatusSuccessTitle : L10n.textStatusFailureTitle
    view.setAnimation(with: transactionStatus)
    view.setStatusTitle(statusTitle)
    view.setFeedback(with: transactionStatus)
    
    if transactionResult.code == .badAuth, let newXdr = xdr {
      view.setXdr(newXdr)
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
    let helpCenter = ZendeskHelper.getHelpCenterController()
    
    let transactionStatusViewController = view as! TransactionStatusViewController
    transactionStatusViewController.navigationController?.pushViewController(helpCenter, animated: true)
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
    let errorMessage = getErrorMessage(from: transactionResult)
    view.setErrorMessage(errorMessage)
  }
  
  private func getErrorMessage(from transactionResult: (code: TransactionResultCode, operationMessageError: String?)) -> String {
    switch transactionResult.code {
    case .success:
      return ""
    case .badAuth:
      if let _ = self.transactionType {
        return ""
      } else {
        return "You have successfully signed this transaction. More signatures required to submit this transaction to the network"
      }
    case .badSeq:
      return "Sequence number does not match source account"
    default:
      if let error = transactionResult.operationMessageError {
        return error
      } else {
        return "Transaction was failed"
      }
    }
  }
  
  private func requestReview() {
    if transactionStatus == .success {
      SKStoreReviewController.requestReview()
    }
  }
}
