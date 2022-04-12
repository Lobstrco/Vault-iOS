import Foundation

extension Notification.Name {
  static let didChangeTransactionList = Notification.Name("didChangeTransactionList")
  static let didRemoveTransaction = Notification.Name("didRemoveTransaction")
  static let didChangeSignerDetails = Notification.Name("didChangeSignerDetails")
  static let didJWTTokenUpdate = Notification.Name("didJWTTokenUpdate")
  static let didPinScreenClose = Notification.Name("didPinScreenClose")
  static let didNicknameSet = Notification.Name("didNicknameSet")
  static let didAllJWTTokensGet = Notification.Name("didAllJWTTokensGet")
  static let didActivePublicKeyChange = Notification.Name("didActivePublicKeyChange")
}
