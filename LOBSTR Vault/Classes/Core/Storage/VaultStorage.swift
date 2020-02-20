import Foundation

public enum Result<T> {
  case success(T)
  case failure(Error)
}

typealias VaultStorageType = VaultStorageCryptography & VaultStorageKeychain

private struct KeychainKey {
  public static let mnemonic = "mnemonic"
  public static let pin = "pin"
  public static let jwt = "jwt"
  public static let publicKey = "publicKey"
}

final public class VaultStorage {
  public let encryptionAlgorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA256AESGCM
  public let securityAttributeAccessible: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
  public let securityAccessControlFlags: SecAccessControlCreateFlags
  
  public let keychain: KeychainManager
  
  private var vaultSecAttrService: String {
    return Environment.buildType == .qa ? "com.ultrastellar.lobstr.qa.vault" :
                                          "com.ultrastellar.lobstr.vault"
  }
  
  private var encryptionPrivateKeyTag: String {
    return Environment.buildType == .qa ? "com.ultrastellar.lobstr.vault.qa.privatekey" :
                                          "com.ultrastellar.lobstr.vault.privatekey"
  }
  
  private var publicKeyKeychainAccessGroupName: String {
    return Environment.buildType == .qa ? "6ZVXG76XRR.com.ultrastellar.lobstr.vault.qa.publickey" :
                                          "6ZVXG76XRR.com.ultrastellar.lobstr.vault.publickey"
  }
  
  init(keychain: KeychainManager = KeychainManagerImpl()) {
    self.keychain = keychain
    
    if Device.hasSecureEnclave {
      securityAccessControlFlags = [.privateKeyUsage]
    } else {
      securityAccessControlFlags = []
    }
  }
  
  public var secKeyCreateRandomKeyParameters: [String: Any] {
    let access =
      SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                      securityAttributeAccessible,
                                      securityAccessControlFlags,
                                      nil)!
    var parameters: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrKeyType as String: kSecAttrKeyTypeEC,
      kSecAttrKeySizeInBits as String: 256,
      kSecPrivateKeyAttrs as String: [
        kSecAttrIsPermanent as String: true,
        kSecAttrApplicationTag as String: encryptionPrivateKeyTag.data(using: .utf8)!,
        kSecAttrAccessControl as String: access,
      ]
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
      kSecAttrService as String: vaultSecAttrService,
      kSecAttrAccount as String: KeychainKey.mnemonic,
      kSecAttrAccessible as String: securityAttributeAccessible,
    ]
  }
  
  public var publicKeyQueryParameters: [String: Any] {
    return [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: vaultSecAttrService,
      kSecAttrAccount as String: KeychainKey.publicKey,
      kSecAttrAccessible as String: securityAttributeAccessible,
      kSecAttrAccessGroup as String: publicKeyKeychainAccessGroupName
    ]
  }
  
  public var pinQueryParameters: [String: Any] {
    return [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: vaultSecAttrService,
      kSecAttrAccount as String: KeychainKey.pin,
      kSecAttrAccessible as String: securityAttributeAccessible
    ]
  }
  
  public var jwtQueryParameters: [String: Any] {
    return [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: vaultSecAttrService,
      kSecAttrAccount as String: KeychainKey.jwt,
      kSecAttrAccessible as String: securityAttributeAccessible
    ]
  }
}
