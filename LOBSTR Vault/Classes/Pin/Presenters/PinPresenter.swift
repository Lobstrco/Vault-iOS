import Foundation

protocol PinPresenter: AnyObject {
  func pinViewDidLoad()
  func pinViewWillAppear()
  func digitButtonWasPressed(with digit: Int)
  func removeButtonWasPressed()
  func helpButtonWasPressed()
  func ignoreSimplePin()
  func changeSimplePin()
}
