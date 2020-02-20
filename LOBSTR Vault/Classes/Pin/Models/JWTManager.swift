import Foundation

protocol JWTManager {
  func isJWTStoredInKeychain() -> Bool
  func store(_ jwt: String) -> Bool
  func getJWT() -> String?
}

struct JWTManagerImpl: JWTManager {
  let vaultStorage: VaultStorageType
  
  init(vaultStorage: VaultStorageType = VaultStorage()) {
    self.vaultStorage = vaultStorage
  }
  
  func store(_ jwt: String) -> Bool {
    
    if isJWTStoredInKeychain() {
      
      if vaultStorage.removeJWTFromKeychain() {
        return vaultStorage.storeJWTInKeychain(jwt)
      } else {
        return false
      }
    } else {
      return vaultStorage.storeJWTInKeychain(jwt)
    }
    
  }
  
  func removeJWT() -> Bool {
    return vaultStorage.removeJWTFromKeychain()
  }
  
  func getJWT() -> String? {    
    return vaultStorage.getJWTFromKeychain()
  }
  
  func isJWTStoredInKeychain() -> Bool {
    guard let _ = vaultStorage.getJWTFromKeychain() else {
      return false
    }
    return true
  }
  
}
