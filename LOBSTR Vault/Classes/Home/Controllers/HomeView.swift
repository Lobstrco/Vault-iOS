import Foundation

protocol HomeView: class {
  func reloadTableViewSections(_ sections: [Int])
  func reloadSignerListRow(_ row: Int)
  func setProgressAnimationForTransactionNumber(isEnabled: Bool)
  func setCopyHUD()
}
