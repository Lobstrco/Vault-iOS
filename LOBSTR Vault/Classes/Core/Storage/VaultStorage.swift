import Foundation

public enum Result<T> {
  case success(T)
  case failure(Error)
}

public enum VaultError: Error {
  case keychainDataNotFound
  
  case decryptionFailed
}

typealias VaultStorageType = VaultStorageCryptography & VaultStorageKeychain

public struct VaultStorage {
  private let encryptionPrivateKeyTag = "com.ultrastellar.lobstr.vault.privatekey"
  private let encryptedMnemonicService = "com.ultrastellar.lobstr.vault.mnemonic"
  private let pinService = "com.ultrastellar.lobstr.vault.pin"
  
  public let encryptionAlgorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA256AESGCM
  public let securityAttributeAccessible: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
  
  public let keychain: KeychainManager
  
  init(keychain: KeychainManager = KeychainManagerImpl()) {
    self.keychain = keychain
  }
  
  public var secKeyCreateRandomKeyParameters: [String: Any] {
    let access =
      SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                      securityAttributeAccessible,
                                      [.privateKeyUsage],
                                      nil)!
    var parameters: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrKeyType as String: kSecAttrKeyTypeEC,
      kSecAttrKeySizeInBits as String: 256,
      kSecPrivateKeyAttrs as String: [
        kSecAttrIsPermanent as String: true,
        kSecAttrApplicationTag as String: encryptionPrivateKeyTag.data(using: .utf8)!,
        kSecAttrAccessControl as String: access,
      ],
    ]
    
    if Device.hasSecureEnclave {
      parameters[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
    }
    
    return parameters
  }
  
  public var encryptionPrivateKeyQueryParameters: [String: Any] {
    return [
      kSecClass as String: kSecClassKey,
      kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
      kSecReturnRef as String: true,
      kSecAttrApplicationTag as String: encryptionPrivateKeyTag.data(using: .utf8)!,
    ]
  }
  
  public var encryptedMnemonicQueryParameters: [String: Any] {
    return [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: encryptedMnemonicService,
      kSecAttrAccessible as String: securityAttributeAccessible,
    ]
  }
  
  public var pinQueryParameters: [String: Any] {
    return [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: pinService,
      kSecAttrAccessible as String: securityAttributeAccessible,
    ]
  }
}
