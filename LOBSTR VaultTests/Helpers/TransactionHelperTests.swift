import XCTest
@testable import LOBSTR_Vault

class TransactionHelperTests: XCTestCase {

  func testValidatedDateShouldBeReceived() {
    let date = "2018-12-27T13:54:52.137904Z"
    let expectedDate = "Dec 27, 2018, 16:54"
    
    let newDate = TransactionHelper.getValidatedDate(from: date)
    
    XCTAssertEqual(expectedDate, newDate, "")
  }

}
