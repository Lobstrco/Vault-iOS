@testable import LOBSTR_Vault
import XCTest


class StringExtensionTests: XCTestCase {

  func testStringShouldBeStellarPublicAddress() {
    let str = "GGD7XRQF7KOVT47RNWBHOPP2QJCNRCWDRXQ64SC7T7K5AGC47236B4IK"
    
    XCTAssert(str.isStellarPublicAddress, "Expected to be stellar public address")
  }
  
  func testShortStringShouldNotBeStellarPublicAddress() {
    let str = "GGD7XRQ"
        
    XCTAssertFalse(str.isStellarPublicAddress, "Expected not to be stellar public address")
  }

  func testStringDoesNotStartWithGSymbolShouldNotBeStellarPublicAddress() {
    let str = "FGD7XRQF7KOVT47RNWBHOPP2QJCNRCWDRXQ64SC7T7K5AGC47236B4IK"
        
    XCTAssertFalse(str.isStellarPublicAddress, "Expected not to be stellar public address")
  }
  
  func testPublicKeyShouldBeTruncated() {
    let publicKey = "GGD7XRQF7KOVT47RNWBHOPP2QJCNRCWDRXQ64SC7T7K5AGC47236B4IK"
    let expectedTruncatedPublicKey = "GGD7XR...36B4IK"
    
    XCTAssertEqual(expectedTruncatedPublicKey, publicKey.getTruncatedPublicKey())
  }

}
