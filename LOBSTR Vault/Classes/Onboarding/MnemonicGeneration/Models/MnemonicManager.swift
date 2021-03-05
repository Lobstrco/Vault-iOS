import Foundation

protocol MnemonicManager {
  func encryptAndStoreInKeychain(mnemonic: String) -> Bool
  func getDecryptedMnemonicFromKeychain(completion: @escaping (Result<String>) -> Void)
  func isMnemonicStoredInKeychain() -> Bool
}

final public class MnemonicManagerImpl: MnemonicManager {
  
  let vaultStorage: VaultStorageType
  
  init(vaultStorage: VaultStorageType = VaultStorage()) {
    self.vaultStorage = vaultStorage
  }
  
  @discardableResult
  func encryptAndStoreInKeychain(mnemonic: String) -> Bool {
    guard let publicKey = vaultStorage.createKeyPair() else {
      fatalError("Cannot create public key.")
    }
    
    guard let plainData = mnemonic.data(using: .utf8) else {
      fatalError("Cannot convert mnemonic string to data.")
    }
    
    let cipherData = vaultStorage.encrypt(plainData, with: publicKey)
    
    let result = vaultStorage.storeEncryptedMnemonicInKeychain(data: cipherData!)
    
    return result
  }
  
  func getDecryptedMnemonicFromKeychain(completion: @escaping (Result<String>) -> Void) {
    let cipherDataFromKeychain = vaultStorage.getEncryptedMnemonicFromKeychain()
    
    vaultStorage.decrypt(cipherDataFromKeychain!) { result in
      switch result {
      case .success(let decryptedData):
        let mnemonic = String(bytes: decryptedData, encoding: .utf8)!
        completion(.success(mnemonic))
      case .failure(let error):
        completion(.failure(error))
      }

    }
  }
  
  func isMnemonicStoredInKeychain() -> Bool {
    guard let _ = vaultStorage.getEncryptedMnemonicFromKeychain() else {
      return false
    }
    return true
  }
  
}
