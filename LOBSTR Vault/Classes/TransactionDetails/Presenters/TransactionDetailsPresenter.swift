import Foundation

protocol TransactionDetailsPresenter {
  var transactionListIndex: Int? { get set }
  var sections: [TransactionDetailsSection] { get }
  
  var numberOfAcceptedSignatures: Int { get }
  var numberOfNeddedSignatures: Int { get }
  var numberOfOperation: Int { get }
  
  func confirmButtonWasPressed()
  func denyButtonWasPressed()
  func denyOperationWasConfirmed()
  func confirmOperationWasConfirmed()
  func transactionDetailsViewDidLoad()
  func operationWasSelected(by index: Int)
}

protocol TransactionDetailsView: class {
  func setConfirmationAlert()
  func setDenyingAlert()
  func setErrorAlert(for error: Error)
  func setProgressAnimation(isEnable: Bool)
  func registerTableViewCell(with cellName: String)
  func setConfirmButtonWithError(isInvalid: Bool)
  func setTitle(_ title: String)
  func disableBackButton()
  func openTransactionListScreen()
  func reloadData()
  func reloadSignerListRow(_ row: Int)
}

enum TransactionType {
  case imported
  case standard
}

enum SignatureStatus {
  case accepted
  case pending
}
