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
  func viewTransactionDetailsButtonWasPressed()
  func copySignedXdrButtonWasPressed()
}

protocol TransactionStatusView: class {
  func setStatusTitle(_ title: String)
  func setErrorMessage(_ message: String)
  func setXdr(_ xdr: String)
  func setAnimation(with status: TransactionStatus)
  func setFeedback(with status: TransactionStatus)
  func copy(_ xdr: String)
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
    
    if transactionResult.code != .success, let newXdr = xdr {
      view.setXdr(newXdr)
    }
  }
  
  func copyXDRButtonWasPressed(xdr: String) {
    UIPasteboard.general.string = xdr
  }
  
  func doneButtonWasPressed() {
    let transactionStatusViewController = view as! TransactionStatusViewController
    transactionStatusViewController.navigationController?.setNavigationBarAppearanceWithoutSeparatorForStandardAppearance()
    transactionStatusViewController.navigationController?.popToRootViewController(animated: true)
    requestReview()
  }
  
  func helpButtonWasPressed() {
    let helpCenter = ZendeskHelper.getHelpCenterController()
    
    let transactionStatusViewController = view as! TransactionStatusViewController
    transactionStatusViewController.navigationController?.pushViewController(helpCenter, animated: true)
  }
  
  func viewTransactionDetailsButtonWasPressed() {
    guard let xdr = xdr else { return }
    UtilityHelper.openStellarLaboratory(for: xdr)
  }
  
  func copySignedXdrButtonWasPressed() {
    guard let xdr = xdr else { return }
    view.copy(xdr)
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
    
    if let operationMessageError = transactionResult.operationMessageError {
      return operationMessageError
    } else {
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
      case .failed:
        return "One of the operations failed."
      case .tooEarly:
        return "Ledger closeTime before minTime value in the transaction."
      case .tooLate:
        return "Ledger closeTime after maxTime value in the transaction."
      case .missingOperation:
        return "No operation was specified."
      case .insufficientBalance:
        return "Fee would bring account below minimum reserve."
      case .noAccount:
        return "Source account not found."
      case .insufficientFee:
        return "Fee is too small."
      case .badAuthExtra:
        return "Unused signatures attached to transaction."
      case .internalError:
        return "An unknown error occurred."
      case .basSponsorship:
        return "Sponsorship not ended."
      case .feeBumpInnerFailed:
        return "Fee bump inner transaction failed."
      default:
        if let error = transactionResult.operationMessageError {
          return error
        } else {
          return "Transaction was failed"
        }
      }
    }
  }
  
  private func requestReview() {
    if transactionStatus == .success {
      SKStoreReviewController.requestReview()
    }
  }
}
