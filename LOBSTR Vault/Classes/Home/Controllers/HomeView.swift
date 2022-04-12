import Foundation

protocol HomeView: class {
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
}
