import Foundation

protocol HomeView: class {
  func setProgressAnimationForTransactionNumber()
  func setCopyHUD()
  func setPublicKey(_ publicKey: String)
  func setTransactionNumber(_ transactionNumber: String)
  func setSignedAccountsList(_ signedAccounts: [SignedAccount])
  func setNumberOfSignedAccount(_ number: Int)
  func setAccountLabel()
}
