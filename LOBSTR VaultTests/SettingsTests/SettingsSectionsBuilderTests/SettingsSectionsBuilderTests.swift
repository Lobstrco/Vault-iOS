@testable import LOBSTR_Vault
import XCTest

class SettingsSectionsBuilderTests: XCTestCase {
  
  var sut: SettingsSectionsBuilder!
  
  override func setUp() {
    sut = SettingsSectionsBuilderImpl()
  }

  override func tearDown() {
    sut = nil
  }
  
  func testSettingsSections() {
    let wallet = SettingsSection(type: .account, rows: [.publicKey])

    let security = SettingsSection(type: .security,
                                   rows: [.mnemonicCode, .biometricId, .changePin])
    
    let about = SettingsSection(type: .about, rows: [.version, .help])
    
    let expectedSections: [SettingsSection] = [wallet, security, about]
    let resultSections = sut.buildSections()
    
    XCTAssertEqual(resultSections, expectedSections)
  }
  
  
}
