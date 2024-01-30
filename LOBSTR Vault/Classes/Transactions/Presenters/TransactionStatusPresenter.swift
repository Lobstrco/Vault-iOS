import Foundation
import UIKit
import stellarsdk
import StoreKit

enum TransactionStatus: String {
  case success = "success"
  case failure = "failure"
  case badAuth = "badAuth"
}

protocol TransactionStatusPresenter {
  init(view: TransactionStatusView,
       transactionResult: (TransactionResultCode, String?),
       xdr: String?,
       transactionType: ServerTransactionType?,
       transactionHash: String?)
  func transactionStatusViewDidLoad()
  func copyXDRButtonWasPressed(xdr: String)
  func doneButtonWasPressed()
  func helpButtonWasPressed()
  func viewTransactionDetailsButtonWasPressed()
  func copySignedXdrButtonWasPressed()
  func viewDetailsButtonWasPressed()
}

protocol TransactionStatusView: AnyObject {
  func setStatusTitle(_ title: String)
  func setDescriptionMessage(_ message: String, transactionStatus: TransactionStatus)
  func setXdr(_ xdr: String)
  func setAnimation(with status: TransactionStatus)
  func setFeedback(with status: TransactionStatus)
  func copy(_ xdr: String)
  func setViewDetailsButton(isHidden: Bool, title: String)
  func showOperationMessageErrorDescriptionAlert(_ error: String)
}

class TransactionStatusPresenterImpl {
  
  private var view: TransactionStatusView
  private var transactionResult: (code: TransactionResultCode, operationMessageError: String?)
  private var xdr: String?
  private var transactionType: ServerTransactionType?
  private var transactionHash: String?
  private var transactionStatus: TransactionStatus = .failure
  
  var operationMessageErrorDescription: String = ""
  
  required init(view: TransactionStatusView,
                transactionResult: (TransactionResultCode, String?),
                xdr: String?,
                transactionType: ServerTransactionType?,
                transactionHash: String?) {
    self.view = view
    self.transactionResult = transactionResult
    self.xdr = xdr
    self.transactionType = transactionType
    self.transactionHash = transactionHash
  }
}

// MARK: - TransactionStatusPresenter

extension TransactionStatusPresenterImpl: TransactionStatusPresenter {
  
  func transactionStatusViewDidLoad() {
    transactionStatus = getTransactionStatus(by: transactionResult.code)
    displayErrorMessage()
    if transactionStatus == .success {
      UserDefaultsHelper.actualTransactionNumber -= 1
      UserDefaultsHelper.badgesCounter = UserDefaultsHelper.actualTransactionNumber
    }
    
    let statusTitle = transactionStatus == .failure ? L10n.textStatusFailureTitle : L10n.textStatusSuccessTitle

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
    let transactionStatusViewController = view as! TransactionStatusViewController
    let helpViewController = FreshDeskHelper.getHelpCenterController()
    transactionStatusViewController.navigationController?.present(helpViewController, animated: true)
  }
  
  func viewTransactionDetailsButtonWasPressed() {
    guard let xdr = xdr else { return }
    UtilityHelper.openStellarLaboratory(for: xdr)
  }
  
  func copySignedXdrButtonWasPressed() {
    guard let xdr = xdr else { return }
    view.copy(xdr)
  }
  
  func viewDetailsButtonWasPressed() {
    switch transactionStatus {
    case .success:
      guard let transactionHash = transactionHash,
            let url = URL(string: "https://stellar.expert/explorer/public/tx/\(transactionHash)")
      else { return }
      
      let transactionStatusViewController = view as! TransactionStatusViewController
      let safariViewController = MainSafariViewController(url: url)
      safariViewController.modalPresentationStyle = .pageSheet
      transactionStatusViewController.navigationController?.present(safariViewController, animated: true)
    case .failure:
      view.showOperationMessageErrorDescriptionAlert(operationMessageErrorDescription)
    default:
      break
    }
  }
}

// MARK: - Private

extension TransactionStatusPresenterImpl {
  
  private func getTransactionStatus(by resultCode: TransactionResultCode) -> TransactionStatus {
    switch resultCode {
    case .success:
      return .success
    case .badAuth:
      return .badAuth
    default:
      return .failure
    }
  }
  
  private func displayErrorMessage() {
    let errorMessage = getErrorMessage(from: transactionResult)
    view.setDescriptionMessage(errorMessage, transactionStatus: transactionStatus)
  }
  
  private func getErrorMessage(from transactionResult: (code: TransactionResultCode, operationMessageError: String?)) -> String {
    
    if let operationMessageError = transactionResult.operationMessageError {
      let messageErrorTitle = splitOperationMessageError(operationMessageError)
      view.setViewDetailsButton(isHidden: operationMessageErrorDescription.isEmpty,
                                title: L10n.textBtnErrorViewDetails)
      return messageErrorTitle
    } else {
      if transactionHash != nil, transactionStatus == .success {
        view.setViewDetailsButton(isHidden: false,
                                  title: L10n.textBtnViewOnNetworkExplorer)
      }
      switch transactionResult.code {
      case .success:
        return L10n.textStatusSuccessDescription
      case .badAuth:
        if self.transactionType != nil {
          return ""
        } else {
          return L10n.textStatusNeedMoreSignaturesDescription
        }
      case .badSeq:
        return L10n.txBadSeq
      case .failed:
        return L10n.txFailed
      case .tooEarly:
        return L10n.txTooEarly
      case .tooLate:
        return L10n.txTooLate
      case .missingOperation:
        return L10n.txMissingOperation
      case .insufficientBalance:
        return L10n.txInsufficientBalance
      case .noAccount:
        return L10n.txNoAccount
      case .insufficientFee:
        return L10n.txInsufficientFee
      case .badAuthExtra:
        return L10n.txBadAuthExtra
      case .internalError:
        return L10n.txInternalError
      case .badSponsorship:
        return L10n.txBadSponsorship
      case .feeBumpInnerFailed:
        return L10n.txBumpInnerFailed
      default:
        if let error = transactionResult.operationMessageError {
          return error
        } else {
          return L10n.txCommonError
        }
      }
    }
  }
  
  private func requestReview() {
    if transactionStatus == .success {
      SKStoreReviewController.requestReview()
    }
  }
  
  private func splitOperationMessageError(_ error: String) -> String {
    var shortMessageError = ""
    let operationMessageErrorArray = error.components(separatedBy: "failed ")
    if operationMessageErrorArray.count == 2 {
      if let shortError = operationMessageErrorArray.first, let errorDescription = operationMessageErrorArray.last {
        shortMessageError = shortError + "failed"
        operationMessageErrorDescription = errorDescription
      }
    }
    return shortMessageError
  }
}
