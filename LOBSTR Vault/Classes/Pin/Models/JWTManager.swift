import Foundation

protocol JWTManager {
  func isJWTStoredInKeychain() -> Bool
  func store(_ jwt: String, for publicKey: String) -> Bool
  func getJWT() -> String?
  
  func store(jwtTokens: [String: String]) -> Bool
}

struct JWTManagerImpl: JWTManager {
  let vaultStorage: VaultStorageType
  
  init(vaultStorage: VaultStorageType = VaultStorage()) {
    self.vaultStorage = vaultStorage
  }
  
  func store(_ jwt: String, for publicKey: String) -> Bool {
    // Multiaccount support case
    if let jwtTokens = vaultStorage.getJWTTokensFromKeychain() {
      var tokens = jwtTokens
      if let key = tokens.keys.first(where: { key in key == publicKey }) {
        tokens[key] = jwt
      } else {
        tokens[UserDefaultsHelper.activePublicKey] = jwt
      }
      
      if vaultStorage.removeJWTTokensFromKeychain() {
        return vaultStorage.storeJWTTokensInKeychain(tokens)
      } else {
        return false
      }
    } else {
      // One account
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
  }
  
  func store(jwtTokens: [String: String]) -> Bool {
    if isJWTStoredInKeychain() {
      if vaultStorage.removeJWTFromKeychain() {
        return vaultStorage.storeJWTTokensInKeychain(jwtTokens)
      } else {
        return false
      }
    } else {
      if vaultStorage.removeJWTTokensFromKeychain() {
        return vaultStorage.storeJWTTokensInKeychain(jwtTokens)
      } else {
        return false
      }
    }
  }
  
  func removeJWT() -> Bool {
    return vaultStorage.removeJWTFromKeychain()
  }
  
  func getJWT() -> String? {
    var jwtToken: String?
    // One account
    if let jwt = vaultStorage.getJWTFromKeychain() {
      jwtToken = jwt
    }
    // Multiaccount support case
    else if let jwtTokens = vaultStorage.getJWTTokensFromKeychain() {
      if let key = jwtTokens.keys.first(where: { key in
        key == UserDefaultsHelper.activePublicKey
      }) {
        jwtToken = jwtTokens[key]
      }
    }
    return jwtToken
  }
  
  func isJWTStoredInKeychain() -> Bool {
    guard let _ = vaultStorage.getJWTFromKeychain() else {
      return false
    }
    return true
  }
}
