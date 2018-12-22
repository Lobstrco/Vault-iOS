@testable import LOBSTR_Vault
import XCTest

class PinManagerTests: XCTestCase {
  
  var sut: PinManager!
  
  override func setUp() {
    super.setUp()
    
    sut = PinManagerImpl()
  }

  override func tearDown() {
    super.tearDown()
  }
  
  func testValidatorShouldReturnTrueIfPinsAreEqual() {
    let pin1 = "123456"
    let pin2 = "123456"
    
    let result = sut.validate(pin1, pin2)
    
    XCTAssertTrue(result, "Exptected equal pins.")
  }
  
  func testValidatorShouldReturnFalseIfPinsAreNotEqual() {
    let pin1 = "123456"
    let pin2 = "000000"
    
    let result = sut.validate(pin1, pin2)
    
    XCTAssertFalse(result, "Exptected not equal pins.")
  }
}
