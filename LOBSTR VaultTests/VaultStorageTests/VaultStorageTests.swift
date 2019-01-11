@testable import LOBSTR_Vault
import XCTest

class VaultStorageTests: XCTestCase {
  let encryptionPrivateKeyTag = "com.ultrastellar.lobstr.vault.privatekey".data(using: .utf8)!
  let encryptedMnemonicService = "com.ultrastellar.lobstr.vault.mnemonic"
  let pinService = "com.ultrastellar.lobstr.vault.pin"
  let jwtService = "com.ultrastellar.lobstr.vault.jwt"
  
  var sut: VaultStorage!
  
  override func setUp() {
    super.setUp()
    clearKeychain()
    sut = VaultStorage()
  }
  
  override func tearDown() {
    clearKeychain()
    super.tearDown()
  }
  
  func testEncryptionPrivateKeyCreationParameters() {
    let parameters = sut.secKeyCreateRandomKeyParameters
    
    let secClass = parameters[kSecClass as String] as! CFString
    XCTAssertEqual(secClass, kSecClassKey,
                   "Expected security class for storing crypto key.")
    
    let secAttrKeyType = parameters[kSecAttrKeyType as String] as! CFString
    XCTAssertEqual(secAttrKeyType, kSecAttrKeyTypeEC,
                   "Expected elliptic curve key type.")
    
    let secAttrKeySizeInBits = parameters[kSecAttrKeySizeInBits as String] as! Int
    XCTAssertEqual(secAttrKeySizeInBits, 256,
                   "Expected key size 256 bits.")
    
    // If device has Secure Enclave expected to store key there.
    if Device.hasSecureEnclave {
      let secAttrTokenID = parameters[kSecAttrTokenID as String] as! CFString
      XCTAssertEqual(secAttrTokenID, kSecAttrTokenIDSecureEnclave,
                     "Expected an item should be stored in the device's Secure Enclave.")
    }
    
    let secPrivateKeyAttrs = parameters[kSecPrivateKeyAttrs as String] as! [String: Any]
    XCTAssertNotNil(secPrivateKeyAttrs,
                    "Expected private keys attributes not nil.")
    
    let secAttrIsPermanent = secPrivateKeyAttrs[kSecAttrIsPermanent as String] as! Bool
    XCTAssertEqual(secAttrIsPermanent, true,
                   "Expected crypto key should be stored in the default keychain at creation time.")
    
    let secAttrApplicationTag = secPrivateKeyAttrs[kSecAttrApplicationTag as String] as! Data
    XCTAssertEqual(secAttrApplicationTag, encryptionPrivateKeyTag,
                   "Expected application tag for encryption private key.")
    
    var securityAccessControlFlags: SecAccessControlCreateFlags = []
    
    if Device.hasSecureEnclave {
      securityAccessControlFlags = [.privateKeyUsage]
    }
    
    let access =
      SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                      kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                      securityAccessControlFlags,
                                      nil)!
    let secAttrAccessControl = secPrivateKeyAttrs[kSecAttrAccessControl as String] as! SecAccessControl
    XCTAssertEqual(secAttrAccessControl, access,
                   "Expected special access contol flags.")
  }
  
  func testEncryptionPrivateKeyQueryParameters() {
    let parameters = sut.encryptionPrivateKeyQueryParameters
    
    let secClass = parameters[kSecClass as String] as! CFString
    XCTAssertEqual(secClass, kSecClassKey,
                   "Expected security class for storing crypto key.")
    
    let secAttrKeyClass = parameters[kSecAttrKeyClass as String] as! CFString
    XCTAssertEqual(secAttrKeyClass, kSecAttrKeyClassPrivate,
                   "Expected private key class.")
    
    let secReturnRef = parameters[kSecReturnRef as String] as! Bool
    XCTAssertEqual(secReturnRef, true,
                   "Expected return a reference to an item.")
    
    let secAttrApplicationTag = parameters[kSecAttrApplicationTag as String] as! Data
    XCTAssertEqual(secAttrApplicationTag, encryptionPrivateKeyTag,
                   "Expected application tag for encryption private key.")
  }
  
  func testEncryptedMnemonicQueryParameters() {
    let parameters = sut.encryptedMnemonicQueryParameters
    
    let secClass = parameters[kSecClass as String] as! CFString
    XCTAssertEqual(secClass, kSecClassGenericPassword,
                   "Expected security class for storing generic password.")
  
    let secAttrService = parameters[kSecAttrService as String] as! CFString
    XCTAssertEqual(secAttrService, encryptedMnemonicService as CFString,
                   "Expected service string for encrypted mnemonic.")
    
    let secAttrAccessible = parameters[kSecAttrAccessible as String] as! CFString
    XCTAssertEqual(secAttrAccessible, kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                   "Expected accessible level Accessible when unlocked this device only.")
  }
  
  func testPinQueryParameters() {
    let parameters = sut.pinQueryParameters
    
    let secClass = parameters[kSecClass as String] as! CFString
    XCTAssertEqual(secClass, kSecClassGenericPassword,
                   "Expected security class for storing generic password.")
    
    let secAttrService = parameters[kSecAttrService as String] as! CFString
    XCTAssertEqual(secAttrService, pinService as CFString,
                   "Expected service string for pin.")
    
    let secAttrAccessible = parameters[kSecAttrAccessible as String] as! CFString
    XCTAssertEqual(secAttrAccessible, kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                   "Exptected kSecAttrAccessibleWhenUnlockedThisDeviceOnly level.")
  }
  
  func testJWTQueryParameters() {
    let parameters = sut.jwtQueryParameters
    
    let secClass = parameters[kSecClass as String] as! CFString
    XCTAssertEqual(secClass, kSecClassGenericPassword,
                   "Expected security class for storing generic password.")
    
    let secAttrService = parameters[kSecAttrService as String] as! CFString
    XCTAssertEqual(secAttrService, jwtService as CFString,
                   "Expected service string for jwt.")
    
    let secAttrAccessible = parameters[kSecAttrAccessible as String] as! CFString
    XCTAssertEqual(secAttrAccessible, kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                   "Exptected kSecAttrAccessibleWhenUnlockedThisDeviceOnly level.")
  }
  
  
  func testEncryptionAlgorithmShouldBeEciesEncryptionCofactorX963SHA256AESGCM() {
    XCTAssertEqual(sut.encryptionAlgorithm,
                   .eciesEncryptionCofactorX963SHA256AESGCM,
                   "Expected eciesEncryptionCofactorX963SHA256AESGCM algorithm.")
  }
  
  func testSecurityAttributeAccessibleShouldBeAccessibleWhenUnlockedThisDeviceOnly() {
    XCTAssertEqual(sut.securityAttributeAccessible,
                   kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                   "Expected kSecAttrAccessibleWhenUnlockedThisDeviceOnly level.")
  }
  
  func testSecurityAccessControlFlagsShouldHavePrivateKeyUsageIfSecureEnclaveAvailable() {
    
    var securityAccessControlFlags: SecAccessControlCreateFlags = []
    
    if Device.hasSecureEnclave {
      securityAccessControlFlags = [.privateKeyUsage]
    }
    
    XCTAssertEqual(sut.securityAccessControlFlags, securityAccessControlFlags)
  }
  
  func testEncryptionAndDecryptionOfMnemonicAndWorkWithKeychain() {
    let publicKey = sut.createKeyPair()
    
    let plainData = "Sample text".data(using: .utf8)!
    
    let cipherData = sut.encrypt(plainData, with: publicKey!)
    XCTAssertNotNil(cipherData, "Expected cipher data not nil.")
    
    let success = sut.storeEncryptedMnemonicInKeychain(data: cipherData!)
    XCTAssertTrue(success, "Expected successful storing in keychain.")
    
    let cipherDataFromKeychain = sut.getEncryptedMnemonicFromKeychain()
    XCTAssertEqual(cipherDataFromKeychain, cipherData,
                   "Expected successful retrieving data from keychain.")
    
    let expectation = XCTestExpectation(description: "Successfull Decryption")
    
    sut.decrypt(cipherDataFromKeychain!) { result in
      switch result {
      case .success(let decryptedData):
        XCTAssertEqual(decryptedData, plainData,
        "Expected successful decryption of data.")
      case .failure:
        break
      }
      
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 1.0)
  }

  func testStoringAndRetrievingPinFromKeychain() {
    let pin = "123456"
    
    let result = sut.storePinInKeychain(pin)
    XCTAssertTrue(result, "Expected storing pin in keychain.")
    
    let pinFromKeychain = sut.getPinFromKeychain()
    XCTAssertEqual(pinFromKeychain, pin, "Expected successful getting of pin.")
  }
}

// MARK: - Helpers

extension VaultStorageTests {
  private func clearKeychain() {
    let secItemClasses = [kSecClassGenericPassword,
                          kSecClassInternetPassword,
                          kSecClassCertificate,
                          kSecClassKey,
                          kSecClassIdentity]
    for secItemClass in secItemClasses {
      let dictionary = [kSecClass as String: secItemClass]
      SecItemDelete(dictionary as CFDictionary)
    }
  }
}
