import Foundation

protocol VaultStorageKeychain {
  func storeEncryptedMnemonicInKeychain(data: Data) -> Bool
  func storePinInKeychain(_ pin: String) -> Bool
  func storeJWTInKeychain(_ jwt: String) -> Bool
  
  func removeJWTFromKeychain() -> Bool
  func removePinFromKeychain() -> Bool
  
  func getEncryptedMnemonicFromKeychain() -> Data?
  func getPinFromKeychain() -> String?
  func getJWTFromKeychain() -> String?
}

// MARK: - VaultStorageKeychain

extension VaultStorage: VaultStorageKeychain {
  @discardableResult
  public func storeEncryptedMnemonicInKeychain(data: Data) -> Bool {
    return keychain.store(data, with: encryptedMnemonicQueryParameters)
  }
  
  public func storePinInKeychain(_ pin: String) -> Bool {
    return storeStringInKeychain(pin, with: pinQueryParameters)
  }
  
  public func storeJWTInKeychain(_ jwt: String) -> Bool {
    return storeStringInKeychain(jwt, with: jwtQueryParameters)
  }
  
  public func removeJWTFromKeychain() -> Bool {
    return keychain.removeData(with: jwtQueryParameters)
  }
  
  func removePinFromKeychain() -> Bool {
    return keychain.removeData(with: pinQueryParameters)
  }
  
  public func getEncryptedMnemonicFromKeychain() -> Data? {
    guard let data = keychain.getData(with: encryptedMnemonicQueryParameters)
    else { return nil}
    
    return data
  }
  
  public func getPinFromKeychain() -> String? {
    return getStringFromKeychain(with: pinQueryParameters)
  }
  
  public func getJWTFromKeychain() -> String? {
    return getStringFromKeychain(with: jwtQueryParameters)
  }
  
  private func storeStringInKeychain(_ string: String,
                                     with parameters: [String: Any]) -> Bool {
    guard let data = string.data(using: .utf8) else { return false }
    return keychain.store(data, with: parameters)
  }
  
  private func getStringFromKeychain(with parameters: [String: Any]) -> String? {
    guard let data = keychain.getData(with: parameters)
    else { return nil }
    
    return String(bytes: data, encoding: .utf8)
  }
}
