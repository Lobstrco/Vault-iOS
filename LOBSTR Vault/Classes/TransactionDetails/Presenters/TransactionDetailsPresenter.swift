import Foundation
import stellarsdk

enum ActionSheetType {
  case publicKey(isNicknameSet: Bool, type: NicknameDialogType = .otherAccount, isVaultSigner: Bool = false)
  case assetCode
  case nativeAssetCode
}

protocol TransactionDetailsPresenter {
  var transactionListIndex: Int? { get set }
  var sections: [TransactionDetailsSection] { get }
  
  var numberOfAcceptedSignatures: Int { get }
  var numberOfNeededSignatures: Int { get }
  var numberOfOperation: Int { get }
  
  var isNeedToShowHelpfulMessage: Bool { get }
  var isNeedToShowSignaturesNumber: Bool { get }
  
  var storageAccounts: [SignedAccount] { get }
  
  func confirmButtonWasPressed()
  func denyButtonWasPressed()
  func denyOperationWasConfirmed()
  func confirmOperationWasConfirmed()
  func transactionDetailsViewDidLoad()
  func operationWasSelected(by index: Int)
  func publicKeyWasSelected(key: String?)
  func assetCodeWasSelected(code: String?)
  func copyXdr()
  func signedXdr()
  func viewTransactionDetails()
  func copyPublicKey(_ key: String)
  func explorerPublicKey(_ key: String)
  func explorerAsset(_ asset: stellarsdk.Asset)
  func explorerNativeAsset()
  func setNicknameActionWasPressed(with text: String?, for publicKey: String?, nicknameDialogType: NicknameDialogType?)
  func clearNicknameActionWasPressed(_ publicKey: String, nicknameDialogType: NicknameDialogType?)
  func signerWasSelected(_ viewData: SignerViewData?)
  func proceedICloudSyncActionWasPressed()
}

protocol TransactionDetailsView: AnyObject {
  func showConfirmationAlert(with description: String)
  func setDenyingAlert()
  func setErrorAlert(for error: Error)
  func setProgressAnimation(isEnabled: Bool)
  func registerTableViewCell(with cellName: String)
  func setConfirmButtonWithError(isInvalid: Bool, withTextError: String?)
  func hideButtonsWithError(withTextError: String?)
  func setTitle(_ title: String)  
  func openTransactionListScreen()
  func reloadData()
  func reloadSignerListRow(_ row: Int)
  func copy(_ text: String)
  func showActionSheet(_ value: Any?, _ type: ActionSheetType)
  func showAlert(text: String)
  func showICloudSyncAdviceAlert()
  func setSequenceNumberCountAlert()
  func setTransactionAlreadySignedOrDeniedAlert()
  func showNoInternetConnectionAlert()
  func setButtons(isEnabled: Bool)
  func showICloudSyncScreen()
}

enum TransactionType {
  case imported
  case standard
}

enum SignatureStatus {
  case accepted
  case pending
}
