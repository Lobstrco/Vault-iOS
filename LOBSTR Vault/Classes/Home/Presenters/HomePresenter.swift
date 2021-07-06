import Foundation

protocol HomePresenter {
  var sections: [HomeSection] { get }
  var publicKey: String? { get }
  var signedAccounts: [SignedAccount] { get }
  
  func homeViewDidLoad()
  func homeViewDidAppear()
  func copyKeyButtonWasPressed()
  
  func updateSignerDetails()
  func refreshButtonWasPressed()
  
  func moreDetailsButtonWasPressed(with index: Int)
  func copySignerPublicKeyActionWasPressed(with index: Int)
  func explorerSignerAccountActionWasPressed(with index: Int)
  func setAccountNicknameActionWasPressed(with text: String?, by index: Int?)
  func clearAccountNicknameActionWasPressed(by index: Int?)
}
