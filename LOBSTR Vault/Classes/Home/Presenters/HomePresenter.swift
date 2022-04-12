import Foundation

protocol HomePresenter {
  var sections: [HomeSection] { get }
  var publicKey: String? { get }
  var signedAccounts: [SignedAccount] { get }
  var multiaccountPublicKeysCount: Int { get }
  var mainAccounts: [SignedAccount] { get }
  
  func homeViewDidLoad()
  func homeViewDidAppear()
  func copyKeyButtonWasPressed()
  
  func updateSignerDetails()
  func refreshButtonWasPressed()
  
  func moreDetailsButtonWasPressed(for publicKey: String, type: NicknameDialogType)
  func copySignerPublicKeyActionWasPressed(_ publicKey: String)
  func explorerSignerAccountActionWasPressed(_ publicKey: String)
  func setNicknameActionWasPressed(with text: String?, for publicKey: String?, nicknameDialogType: NicknameDialogType?)
  func clearNicknameActionWasPressed(_ publicKey: String, nicknameDialogType: NicknameDialogType?)
  
  func changeActiveAccount()
}
