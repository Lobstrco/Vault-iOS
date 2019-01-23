@testable import LOBSTR_Vault
import XCTest

class BiometricAuthManagerTests: XCTestCase {
  
  var sut: BiometricAuthManager!
  var dataStoreFake: DataStoreFake!
  
  override func setUp() {
    dataStoreFake = DataStoreFake()
    sut = BiometricAuthManagerImpl(dataStore: dataStoreFake)
  }

  override func tearDown() {
    sut = nil
  }
  
  func testBiometricAuthManagerIsBiometricsEnabledShouldReturnFalseWhenNotSet() {
    XCTAssertFalse(sut.isBiometricAuthEnabled)
  }
  
  func testBiometricAuthManagerIsBiometricsEnabledShouldReturnTrueAfterSet() {
    sut.isBiometricAuthEnabled = true
    XCTAssertTrue(sut.isBiometricAuthEnabled)
  }
  
  func testBiometricAuthManagerShouldStoreIsBiometricsEnabledValueInDataStore() {
    sut.isBiometricAuthEnabled = false
    let value = dataStoreFake.bool(forKey: DataStoreKeys.isBiometricAuthEnabledKey)
    XCTAssertEqual(value, false)
  }
  
}

extension BiometricAuthManagerTests {

  class DataStoreFake: KeyValueStorage {
    var store: [String: Any] = [:]
    
    func object(forKey defaultName: String) -> Any? {
      return store[defaultName]
    }
    
    func bool(forKey defaultName: String) -> Bool {
      guard object(forKey: defaultName) != nil else { return false }
      return store[defaultName] as! Bool
    }
    
    func set(_ value: Bool, forKey defaultName: String) {
      store[defaultName] = value
    }
  }
}
