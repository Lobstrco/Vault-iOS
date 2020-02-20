import Foundation

protocol VaultStorageCryptography {
  func createKeyPair() -> SecKey?
  func encrypt(_ data: Data, with publicKey: SecKey) -> Data?
  func decrypt(_ cipherData: Data,
               completion: @escaping (Result<Data>) -> Void)
}

// MARK: - VaultStorageCryptography

extension VaultStorage: VaultStorageCryptography {
  public func createKeyPair() -> SecKey? {
    let parameters = secKeyCreateRandomKeyParameters
    
    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(parameters as CFDictionary, &error),
      let publicKey = SecKeyCopyPublicKey(privateKey) else {
      return nil
    }
    
    return publicKey
  }
  
  public func encrypt(_ data: Data, with publicKey: SecKey) -> Data? {
    guard let cipherData = SecKeyCreateEncryptedData(
      publicKey,
      encryptionAlgorithm,
      data as CFData,
      nil
    ) else {
      return nil
    }
    return cipherData as Data
  }
  
  public func decrypt(_ cipherData: Data,
                      completion: @escaping (Result<Data>) -> Void) {
    let parameters = encryptionPrivateKeyQueryParameters
    var raw: CFTypeRef?
    let status = SecItemCopyMatching(parameters as CFDictionary, &raw)
    
    guard status == errSecSuccess, let privateKey = raw else {
      Logger.security.debug(status)
      if #available(iOS 11.3, *) {
        Logger.security.debug(SecCopyErrorMessageString(status, nil) ?? "")
      }
      completion(.failure(VaultError.VaultStorageError.keychainDataNotFound))
      return
    }
    
    DispatchQueue.main.async {
      guard let plainData = SecKeyCreateDecryptedData(
        privateKey as! SecKey,
        self.encryptionAlgorithm,
        cipherData as CFData,
        nil
      ) else {
        completion(.failure(VaultError.VaultStorageError.decryptionFailed))
        return
      }
      
      completion(.success(plainData as Data))
    }
  }
}
