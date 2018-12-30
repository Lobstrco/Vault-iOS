@testable import LOBSTR_Vault
import XCTest

class MnemonicManagerTests: XCTestCase {
  var sut: MnemonicManager!
  var mockVaultStorage: MockVaultStorage!

  override func setUp() {
    super.setUp()
    mockVaultStorage = MockVaultStorage()
    sut = MnemonicManagerImpl(vaultStorage: mockVaultStorage)
  }

  override func tearDown() {
    super.tearDown()
  }

  func testMnemonicManagerShouldEncryptAndStoreMnemonicInKeychain() {
    let mnemonic = "early trouble captain remember horse forest morning inherit taste priority fatigue thing debris decide guide decrease flavor cluster swarm first crane select stable trim"

    let result = sut.encryptAndStoreInKeychain(mnemonic: mnemonic)

    XCTAssertEqual(mockVaultStorage.createKeyPairCalled, true)
    XCTAssertEqual(mockVaultStorage.encryptCalled,  true)
    XCTAssertEqual(mockVaultStorage.storeMnemonicInKeychainCalled, true)
    XCTAssertEqual(result, true)
  }
  
  func testMnemonicManagerShouldGetMnemonicFromKeychainAndDecrypt() {
    sut.getDecryptedMnemonicFromKeychain { _ in }
    
    XCTAssertEqual(mockVaultStorage.getEncryptedMnemonicsFromKeychainCalled,
                   true)
    XCTAssertEqual(mockVaultStorage.decryptCalled, true)
  }
  
  func testMnemonicManagerShouldCheckIfMnemonicsStored() {
    _ = sut.isMnemonicStoredInKeychain()
    XCTAssertEqual(mockVaultStorage.getEncryptedMnemonicsFromKeychainCalled,
                   true)
  }
  
}

extension MnemonicManagerTests {
  class MockVaultStorage: VaultStorageCryptography, VaultStorageKeychain {
    
    var createKeyPairCalled = false
    var encryptCalled = false
    var storeMnemonicInKeychainCalled = false
    var getEncryptedMnemonicsFromKeychainCalled = false
    var decryptCalled = false
    
    func createKeyPair() -> SecKey? {
      createKeyPairCalled = true
      return dummyPublicKey
    }
    
    func encrypt(_ data: Data, with publicKey: SecKey) -> Data? {
      encryptCalled = true
      return Data()
    }
    
    func decrypt(_ cipherData: Data,
                 completion: @escaping (Result<Data>) -> Void) {
      decryptCalled = true
      return
    }
    
    func storeEncryptedMnemonicInKeychain(data: Data) -> Bool {
      storeMnemonicInKeychainCalled = true
      return true
    }
    
    func storePinInKeychain(_ pin: String) -> Bool {
      return true
    }    
    
    func getEncryptedMnemonicFromKeychain() -> Data? {
      getEncryptedMnemonicsFromKeychainCalled = true
      return Data()
    }
    
    func getPinFromKeychain() -> String? {
      return nil
    }
    
    func storeJWTInKeychain(_ jwt: String) -> Bool {
      return false
    }
    
    func getJWTFromKeychain() -> String? {
      return nil
    }
    
    func removeJWTFromKeychain() -> Bool {
      return false
    }
    
    var dummyPublicKey: SecKey? {
      let publicKey = "BMD7LUJ/1DqB90hoASaTSEU1mcAI80O6XxOg8z2GqzJXJDSd7k/N9LjVl74EV2L77gmgFOTTXqT5ULvCdxtAnu8="
      
      let params: [String: Any] = [
        kSecAttrKeyType as String: kSecAttrKeyTypeEC,
        kSecAttrKeySizeInBits as String: 256,
        kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
        ]
      
      let data = Data(base64Encoded: publicKey)! as CFData
      return SecKeyCreateWithData(data, params as CFDictionary, nil)
    }
  }
}
