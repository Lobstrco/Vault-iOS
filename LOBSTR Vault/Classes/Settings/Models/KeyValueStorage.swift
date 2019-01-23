import Foundation

protocol KeyValueStorage {
  func object(forKey defaultName: String) -> Any?
  func bool(forKey defaultName: String) -> Bool
  func set(_ value: Bool, forKey defaultName: String)
}

struct DataStoreKeys {
  static var isBiometricAuthEnabledKey = "isBiometricAuthEnabledKey"
}

extension UserDefaults: KeyValueStorage {}
