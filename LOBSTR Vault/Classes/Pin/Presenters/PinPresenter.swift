import Foundation

protocol PinPresenter: class {
  func pinViewDidLoad()
  func digitButtonWasPressed(with digit: Int)
  func removeButtonWasPressed()
  func helpButtonWasPressed()
}
