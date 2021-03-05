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
  
  func copySignerPublicKeyActionWasPressed(with index: Int)
  func explorerSignerAccountActionWasPressed(with index: Int)
}
