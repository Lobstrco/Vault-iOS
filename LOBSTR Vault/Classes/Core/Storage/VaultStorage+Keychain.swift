import Foundation

protocol VaultStorageKeychain {
  func storeEncryptedMnemonicInKeychain(data: Data) -> Bool
  func storePinInKeychain(_ pin: String) -> Bool
  
  func getEncryptedMnemonicFromKeychain() -> Data?
  func getPinFromKeychain() -> String?
}

// MARK: - VaultStorageKeychain

extension VaultStorage: VaultStorageKeychain {
  @discardableResult
  public func storeEncryptedMnemonicInKeychain(data: Data) -> Bool {
    return keychain.store(data, with: encryptedMnemonicQueryParameters)
  }
  
  public func storePinInKeychain(_ pin: String) -> Bool {
    guard let data = pin.data(using: .utf8) else { return false }
    return keychain.store(data, with: pinQueryParameters)
  }
  
  public func getEncryptedMnemonicFromKeychain() -> Data? {
    guard let data = keychain.getData(with: encryptedMnemonicQueryParameters)
    else { return nil}
    
    return data
  }
  
  public func getPinFromKeychain() -> String? {
    guard let data = keychain.getData(with: pinQueryParameters)
    else { return nil }
    
    return String(bytes: data, encoding: .utf8)
  }
}
