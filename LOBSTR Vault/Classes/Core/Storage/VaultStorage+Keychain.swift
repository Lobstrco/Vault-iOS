import Foundation

protocol VaultStorageKeychain {
  func storeEncryptedMnemonicInKeychain(data: Data) -> Bool
  func storePinInKeychain(_ pin: String) -> Bool
  func storeJWTInKeychain(_ jwt: String) -> Bool
  func storePublicKeyInKeychain(_ publicKey: String) -> Bool
  func storePublicKeysInKeychain(_ publicKeys: [String]) -> Bool
  func storeJWTTokensInKeychain(_ jwtTokens: [String: String]) -> Bool
  func storeActivePublicKeyInKeychain(_ publicKey: String) -> Bool
    
  func removeJWTFromKeychain() -> Bool
  func removePinFromKeychain() -> Bool
  func removePublicKeysFromKeychain() -> Bool
  func removeJWTTokensFromKeychain() -> Bool
  func removeActivePublicKeyFromKeychain() -> Bool
  
  func getEncryptedMnemonicFromKeychain() -> Data?
  func getPinFromKeychain() -> String?
  func getJWTFromKeychain() -> String?
  func getPublicKeyFromKeychain() -> String?
  func getPublicKeysFromKeychain() -> [String]?
  func getJWTTokensFromKeychain() -> [String: String]?
  func getActivePublicKeyFromKeychain() -> String?
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
  
  public func storeJWTTokensInKeychain(_ jwtTokens: [String: String]) -> Bool {
    return storeDictionaryInKeychain(jwtTokens, with: jwtQueryParameters)
  }
  
  @discardableResult
  public func storePublicKeyInKeychain(_ publicKey: String) -> Bool {
    return storeStringInKeychain(publicKey, with: publicKeyQueryParameters)
  }
  
  @discardableResult
  public func storePublicKeysInKeychain(_ publicKeys: [String]) -> Bool {
    return storeStringsInKeychain(publicKeys, with: publicKeyQueryParameters)
  }
  
  @discardableResult
  public func storeActivePublicKeyInKeychain(_ publicKey: String) -> Bool {
    return storeStringInKeychain(publicKey, with: activePublicKeyQueryParameters)
  }
  
  public func removePublicKeysFromKeychain() -> Bool {
    return keychain.removeData(with: publicKeyQueryParameters)
  }
  
  public func removeJWTFromKeychain() -> Bool {
    return keychain.removeData(with: jwtQueryParameters)
  }
  
  public func removeJWTTokensFromKeychain() -> Bool {
    return keychain.removeData(with: jwtQueryParameters)
  }
  
  public func removeActivePublicKeyFromKeychain() -> Bool {
    return keychain.removeData(with: activePublicKeyQueryParameters)
  }
  
  func removePinFromKeychain() -> Bool {
    return keychain.removeData(with: pinQueryParameters)
  }
  
  public func getEncryptedMnemonicFromKeychain() -> Data? {
    guard let data = keychain.getData(with: encryptedMnemonicQueryParameters)
    else { return nil }
    
    return data
  }
  
  public func getPinFromKeychain() -> String? {
    return getStringFromKeychain(with: pinQueryParameters)
  }
  
  public func getJWTFromKeychain() -> String? {
    return getStringFromKeychain(with: jwtQueryParameters)
  }
  
  public func getPublicKeyFromKeychain() -> String? {
    return getStringFromKeychain(with: publicKeyQueryParameters)
  }
  
  public func getPublicKeysFromKeychain() -> [String]? {
    return getStringsFromKeychain(with: publicKeyQueryParameters)
  }
  
  public func getJWTTokensFromKeychain() -> [String: String]? {
    return getDictionaryFromKeychain(with: jwtQueryParameters)
  }
  
  public func getActivePublicKeyFromKeychain() -> String? {
    return getStringFromKeychain(with: activePublicKeyQueryParameters)
  }
    
  private func storeStringInKeychain(_ string: String,
                                     with parameters: [String: Any]) -> Bool
  {
    guard let data = string.data(using: .utf8) else { return false }
    return keychain.store(data, with: parameters)
  }
  
  private func storeStringsInKeychain(_ strings: [String],
                                      with parameters: [String: Any]) -> Bool
  {
    do {
      let data = try NSKeyedArchiver.archivedData(withRootObject: strings,
                                                  requiringSecureCoding: true)
      return keychain.store(data, with: parameters)
    } catch {
      print("An error occurred while archiving the data: \(error)")
      return false
    }
  }

  private func storeDictionaryInKeychain(_ dict: [String: String],
                                         with parameters: [String: Any]) -> Bool
  {
    do {
      // Ensure that the dictionary to be archived conforms to NSSecureCoding
      let data = try NSKeyedArchiver.archivedData(withRootObject: dict,
                                                  requiringSecureCoding: true)
      return keychain.store(data, with: parameters)
    } catch {
      print("An error occurred while archiving the data: \(error)")
      return false
    }
  }

  private func getStringFromKeychain(with parameters: [String: Any]) -> String? {
    guard let data = keychain.getData(with: parameters)
    else { return nil }
    
    return String(bytes: data, encoding: .utf8)
  }
  
  private func getStringsFromKeychain(with parameters: [String: Any]) -> [String]? {
    guard let data = keychain.getData(with: parameters) else { return nil }
      
    do {
      let arrayFromData = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, NSString.self],
                                                                 from: data) as? [String]
      return arrayFromData
    } catch {
      print("An error occurred while unarchiving the data: \(error)")
      return nil
    }
  }

  private func getDictionaryFromKeychain(with parameters: [String: Any]) -> [String: String]? {
    guard let data = keychain.getData(with: parameters) else { return nil }
      
    do {
      let dictionaryFromData = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self,
                                                                                  NSString.self], from: data) as? [String: String]
      return dictionaryFromData
    } catch {
      print("An error occurred while unarchiving the data: \(error)")
      return nil
    }
  }
}
