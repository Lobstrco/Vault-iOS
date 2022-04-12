//

import Foundation

struct PromtForTransactionDecisionsHelper {
  static var isPromtTransactionDecisionsEnabled: Bool {
    if let _ = VaultStorage().getPublicKeysFromKeychain() {
      guard let key = UserDefaultsHelper.promtForTransactionDecisionsStatuses.keys.first(where: { key in
        key == UserDefaultsHelper.activePublicKey
      }) else { return true }
      
      guard let isPromtTransactionDecisionsEnabled = UserDefaultsHelper.promtForTransactionDecisionsStatuses[key] else { return true }
      return isPromtTransactionDecisionsEnabled
    } else {
      return UserDefaultsHelper.isPromtTransactionDecisionsEnabled
    }
  }
  
  static func setPromtForTransactionDecisionsStatusesDefaultValues() {
    guard let publicKeysFromKeychain = VaultStorage().getPublicKeysFromKeychain() else { return }
    if UserDefaultsHelper.promtForTransactionDecisionsStatuses.isEmpty {
      for publicKeyFromKeychain in publicKeysFromKeychain {
        UserDefaultsHelper.promtForTransactionDecisionsStatuses[publicKeyFromKeychain] = publicKeyFromKeychain == UserDefaultsHelper.activePublicKey ? UserDefaultsHelper.isPromtTransactionDecisionsEnabled : true
      }
    }
  }
  
  
  
}
