import Foundation

protocol HomePresenter {
  func homeViewDidLoad()
  func homeViewDidAppear()
  func copyKeyButtonWasPressed()
  func copySignerKeyButtonWasPressed()
  func updateSignerDetails()
}
