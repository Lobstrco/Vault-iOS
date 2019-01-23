@testable import LOBSTR_Vault
import XCTest

class PinPresenterTests: XCTestCase {
  
  var sut: PinPresenterImpl!
  var pinViewSpy: PinViewSpy!
  
  override func setUp() {
    super.setUp()
    
    pinViewSpy = PinViewSpy()
    sut = PinPresenterImpl(view: pinViewSpy,
                           navigationController: UINavigationController(),
                           mode: .createPinFirstStep)
  }

  override func tearDown() {
    super.tearDown()
  }
  
  func testPinStringShouldBeEmptyAfterInit() {
    XCTAssertTrue(sut.pin.isEmpty)
  }
  
  func testPinPresenterShouldHaveView() {
    XCTAssertNotNil(sut.view)
  }
  
  func testPinLengthShouldBeSixDigits() {
    XCTAssertEqual(sut.pinLength, 6)
  }
  
  func testPinPresenterShouldStoreEnteredDigits() {
    sut.digitButtonWasPressed(with: 1)
    sut.digitButtonWasPressed(with: 2)
    sut.digitButtonWasPressed(with: 3)
    sut.digitButtonWasPressed(with: 4)
    XCTAssertEqual(sut.pin, "1234")
  }
  
  func testPinPresenterShouldClearRemovedDigits() {
    sut.digitButtonWasPressed(with: 1)
    sut.digitButtonWasPressed(with: 2)
    sut.digitButtonWasPressed(with: 3)
    sut.digitButtonWasPressed(with: 4)
    XCTAssertEqual(sut.pin, "1234")
    
    sut.removeButtonWasPressed()
    sut.removeButtonWasPressed()
    
    XCTAssertEqual(sut.pin, "12")
  }
  
}
