//

import Foundation
struct ActivePublicKeyHelper {
  
  private static var isStoreInKeychain: Bool {
    guard let _ = VaultStorage().getActivePublicKeyFromKeychain() else {
      return false
    }
    return true
  }
  
  static func storeInKeychain(_ publicKey: String) {
    if isStoreInKeychain {
      if VaultStorage().removeActivePublicKeyFromKeychain() {
        VaultStorage().storeActivePublicKeyInKeychain(publicKey)
      }
    } else {
      VaultStorage().storeActivePublicKeyInKeychain(publicKey)
    }
  }
}
