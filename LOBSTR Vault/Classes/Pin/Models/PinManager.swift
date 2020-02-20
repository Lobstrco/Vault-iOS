import Foundation

protocol PinManager {
  func validate(_ pin1: String, _ pin2: String) -> Bool
  func isPinStoredInKeychain() -> Bool
  func store(_ pin: String) -> Bool
  func getPin() -> String?
}

struct PinManagerImpl: PinManager {
  let vaultStorage: VaultStorageType
  
  init(vaultStorage: VaultStorageType = VaultStorage()) {
    self.vaultStorage = vaultStorage
  }
  
  func validate(_ pin1: String, _ pin2: String) -> Bool {
    return pin1 == pin2
  }
  
  func store(_ pin: String) -> Bool {
    if isPinStoredInKeychain() {
      
      if vaultStorage.removePinFromKeychain() {
        return vaultStorage.storePinInKeychain(pin)
      } else {
        return false
      }
    } else {
      return vaultStorage.storePinInKeychain(pin)
    }
  }
  
  func getPin() -> String? {
    return vaultStorage.getPinFromKeychain()
  }
  
  func isPinStoredInKeychain() -> Bool {
    guard let _ = vaultStorage.getPinFromKeychain() else {
      return false
    }
    return true
  }
  
}
