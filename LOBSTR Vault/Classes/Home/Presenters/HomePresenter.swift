import Foundation

protocol HomePresenter {
  var sections: [HomeSection] { get }
  
  func homeViewDidLoad()  
  func copyKeyButtonWasPressed()
  
  func updateSignerDetails()
  func refreshButtonWasPressed()
  
  func copySignerPublicKeyActionWasPressed(with index: Int)
  func explorerSignerAccountActionWasPressed(with index: Int)
}
