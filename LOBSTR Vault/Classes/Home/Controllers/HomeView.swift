import Foundation

protocol HomeView: AnyObject {
  func setProgressAnimationForTransactionNumber()
  func setCopyHUD()
  func setPublicKey(_ publicKey: String, _ nickname: String)
  func setTransactionNumber(_ transactionNumber: String)
  func setSignedAccountsList(_ signedAccounts: [SignedAccount])
  func setNumberOfSignedAccount(_ number: Int)
  func setAccountLabel()
  func rotateRefreshButton(isRotating: Bool)
  func actionSheetForSignersListWasPressed(with publicKey: String, isNicknameSet: Bool)
  func setIconCardOrIdenticon()
  func actionSheetForAccountsListWasPressed(isNicknameSet: Bool)
  func setProgressAnimation(isEnabled: Bool)
  func showICloudSyncAdviceAlert()
  func showICloudStatusIsNotAvaliableAlert()
  func showNoInternetConnectionAlert()
  func showICloudSyncScreen()
}
