import Foundation
import LocalAuthentication

protocol BiometricAuthManager {
  var isBiometricAuthEnabled: Bool { get set }
  
  func canEvaluatePolicy() -> Bool
  func authenticateUser(completion: @escaping (Result<Bool>) -> Void)
  
  init(context: AuthСontext, dataStore: KeyValueStorage)
}

class BiometricAuthManagerImpl: BiometricAuthManager {
  required init(context: AuthСontext = LAContext(),
                dataStore: KeyValueStorage = UserDefaults.standard) {
    self.context = context
    self.dataStore = dataStore
  }
  
  private let context: AuthСontext
  private let dataStore: KeyValueStorage
  private var loginReason = "Authenticate to continue"
  
  var isBiometricAuthEnabled: Bool {
    get {
      let key = DataStoreKeys.isBiometricAuthEnabledKey
      guard dataStore.object(forKey: key) != nil
      else { return false }
      return dataStore.bool(forKey: key)
    }
    set {
      let key = DataStoreKeys.isBiometricAuthEnabledKey
      dataStore.set(newValue, forKey: key)
    }
  }
  
  func canEvaluatePolicy() -> Bool {
    return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                     error: nil)
  }
  
  func authenticateUser(completion: @escaping (Result<Bool>) -> Void) {
    guard canEvaluatePolicy() else {
      completion(.failure(VaultError.BiometricError.notAvailable))
      return
    }
    
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                           localizedReason: loginReason) { success, evaluateError in
      if success {
        DispatchQueue.main.async {
          completion(.success(true))
        }
      } else {
        DispatchQueue.main.async {
          switch evaluateError {
          case LAError.authenticationFailed?:
            completion(.failure(VaultError.BiometricError.authenticationFailed))
          case LAError.userCancel?:
            completion(.failure(VaultError.BiometricError.cancelled))
          case LAError.userFallback?:
            completion(.failure(VaultError.BiometricError.fallback))
          default:
            completion(.failure(VaultError.BiometricError.undefined))
          }
        }
      }
    }
  }
}
