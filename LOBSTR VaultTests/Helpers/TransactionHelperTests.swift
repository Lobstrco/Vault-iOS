import XCTest
import stellarsdk
@testable import LOBSTR_Vault

class TransactionHelperTests: XCTestCase {

  func testValidatedDateShouldBeReceived() {
    let date = "2018-12-27T13:54:52.137904Z"
    let expectedDate = "Dec 27, 2018, 16:54"
    
    let newDate = TransactionHelper.getValidatedDate(from: date)
    
    XCTAssertEqual(expectedDate, newDate, "Expected to receive validate date")
  }
  
  func testNamesAndVaulesFromPaymentOperationWithNotNativeAssetsShouldBeRecevied() throws {
    let accountId = "GCG5XRQF7KOVT47RNWBHOPP2QJCNRCWDRXQ64SC7T7K5AGC5WHR4B4IK"
    let expectedNamesAndValues = [("destination", accountId), ("asset", "BTC"), ("amount", "20")]
    let paymentOperation = try PaymentOperation(destination: KeyPair(accountId: accountId),
                                                 asset: Asset.init(type: AssetType.ASSET_TYPE_CREDIT_ALPHANUM4, code: "BTC", issuer: KeyPair(accountId: "GBSTRH4QOTWNSVA6E4HFERETX4ZLSR3CIUBLK7AXYII277PFJC4BBYOG"))!,
                                                 amount: Decimal(string: "20")!)
    
    let namesAndValues = TransactionHelper.getNamesAndValuesOfProperties(from: paymentOperation)
    
    for (index, item) in namesAndValues.enumerated() {
      assertStringPairsEqual(actual: item, expected: expectedNamesAndValues[index])
    }
  }
  
  func testNamesAndVaulesFromPaymentOperationWithNativeAssetsShouldBeRecevied() throws {
    let accountId = "GCG5XRQF7KOVT47RNWBHOPP2QJCNRCWDRXQ64SC7T7K5AGC5WHR4B4IK"
    let expectedNamesAndValues = [("destination", accountId), ("asset", "XLM"), ("amount", "35")]
    let paymentOperation = try PaymentOperation(destination: KeyPair(accountId: accountId),
                                                 asset: Asset.init(type: AssetType.ASSET_TYPE_NATIVE, code: nil, issuer: nil)!,
                                                 amount: Decimal(string: "35")!)
    
    let namesAndValues = TransactionHelper.getNamesAndValuesOfProperties(from: paymentOperation)
    
    for (index, item) in namesAndValues.enumerated() {
      assertStringPairsEqual(actual: item, expected: expectedNamesAndValues[index])
    }
  }
  
  func testNamesAndVaulesFromSetOptionsOperationShouldBeRecevied() throws {
    let expectedNamesAndValues = [("masterKeyWeight", "20"), ("lowThreshold", "10"), ("mediumThreshold", "15"), ("highThreshold", "10")]
    let setOptionsOperation = try SetOptionsOperation(sourceAccount: nil, inflationDestination: nil, clearFlags: nil, setFlags: nil, masterKeyWeight: 20, lowThreshold: 10, mediumThreshold: 15, highThreshold: 10, homeDomain: nil, signer: nil, signerWeight: nil)
    
    let namesAndValues = TransactionHelper.getNamesAndValuesOfProperties(from: setOptionsOperation)
    
    for (index, item) in expectedNamesAndValues.enumerated() {
      assertStringPairsEqual(actual: namesAndValues[index], expected: item)
    }
  }
  
  func testListOfOperationNamesShouldBeRecevied() throws {
    let xdr = "AAAAAI3bxgX6nVnz8W2Cdz36gkTYisON4e5IX5/V0BhdsePAAAAAyAFIyE8AAAAJAAAAAAAAAAAAAAACAAAAAAAAAAEAAAAAq4beUlPpxLFRF2ciNPPNUlULKae/kplLgE8MTCTMwVAAAAAAAAAAANCdwwAAAAAAAAAABQAAAAAAAAAAAAAAAAAAAAEAAAAUAAAAAQAAAAUAAAABAAAABQAAAAEAAAAFAAAAAAAAAAAAAAAAAAAAAV2x48AAAABAvQgSWvqVkVRfzVlFgCEq1BHlij1nWhLjghq9IwRV3S/ruJxzJkle3esf9AE2INQatFqCHtJYzE/4uelK6CxeCw=="
    let expectedOperationNames = ["Payment", "Set Options"]
    
    let operationNames = try TransactionHelper.getListOfOperationNames(from: xdr)
    
    XCTAssertEqual(expectedOperationNames, operationNames, "Expected to receive list of operation names")
  }
  
  func testExceptionShouldBeReceviedWhileGettingListOfOperationNames() {
    let xdr = "wrong xdr"
    
    XCTAssertThrowsError(try TransactionHelper.getListOfOperationNames(from: xdr)) { error in
      XCTAssertEqual(error as? VaultError.TransactionError, VaultError.TransactionError.invalidTransaction)
    }
  }
  
  func testOperationShouldBeReceviedByIndexFromXDR() throws {
    let accountId = "GCVYNXSSKPU4JMKRC5TSENHTZVJFKCZJU67ZFGKLQBHQYTBEZTAVB5QN"
    let operationIndex = 0
    let xdr = "AAAAAI3bxgX6nVnz8W2Cdz36gkTYisON4e5IX5/V0BhdsePAAAAAyAFIyE8AAAAJAAAAAAAAAAAAAAACAAAAAAAAAAEAAAAAq4beUlPpxLFRF2ciNPPNUlULKae/kplLgE8MTCTMwVAAAAAAAAAAANCdwwAAAAAAAAAABQAAAAAAAAAAAAAAAAAAAAEAAAAUAAAAAQAAAAUAAAABAAAABQAAAAEAAAAFAAAAAAAAAAAAAAAAAAAAAV2x48AAAABAvQgSWvqVkVRfzVlFgCEq1BHlij1nWhLjghq9IwRV3S/ruJxzJkle3esf9AE2INQatFqCHtJYzE/4uelK6CxeCw=="
    
    let paymentOperation = try PaymentOperation(destination: KeyPair(accountId: accountId),
                                                 asset: Asset.init(type: AssetType.ASSET_TYPE_NATIVE, code: nil, issuer: nil)!,
                                                 amount: Decimal(string: "350")!)
    
    let operation = try TransactionHelper.getOperation(from: xdr, by: operationIndex) as? PaymentOperation
    
    XCTAssertEqual(paymentOperation.amount, operation?.amount, "Expected to receive amount of payment operation")
    XCTAssertEqual(paymentOperation.asset.type, operation?.asset.type, "Expected to receive asset type of payment operation")
    XCTAssertEqual(paymentOperation.destination.accountId, operation?.destination.accountId, "Expected to receive destination account id of payment operation")
  }
  
  func testInvalidaTransactionErrorShouldBeReceviedWhileGettingOperationByIndex() {
    let xdr = "wrong xdr"
    let operationIndex = 0
    
    XCTAssertThrowsError(try TransactionHelper.getOperation(from: xdr, by: operationIndex)) { error in
      XCTAssertEqual(error as? VaultError.TransactionError, VaultError.TransactionError.invalidTransaction, "Expected to receive invalid transaction error")
    }
  }
  
  func testOutOfOperationRangeErrorShouldBeReceviedWhileGettingOperationByIndex() {
    let xdr = "AAAAAI3bxgX6nVnz8W2Cdz36gkTYisON4e5IX5/V0BhdsePAAAAAyAFIyE8AAAAJAAAAAAAAAAAAAAACAAAAAAAAAAEAAAAAq4beUlPpxLFRF2ciNPPNUlULKae/kplLgE8MTCTMwVAAAAAAAAAAANCdwwAAAAAAAAAABQAAAAAAAAAAAAAAAAAAAAEAAAAUAAAAAQAAAAUAAAABAAAABQAAAAEAAAAFAAAAAAAAAAAAAAAAAAAAAV2x48AAAABAvQgSWvqVkVRfzVlFgCEq1BHlij1nWhLjghq9IwRV3S/ruJxzJkle3esf9AE2INQatFqCHtJYzE/4uelK6CxeCw=="
    let operationIndex = 10
    
    XCTAssertThrowsError(try TransactionHelper.getOperation(from: xdr, by: operationIndex)) { error in
      XCTAssertEqual(error as? VaultError.TransactionError, VaultError.TransactionError.outOfOperationRange, "Expected to receive out of operation range error")
    }
  }
  
  func assertStringPairsEqual(actual: (_: String, _: String), expected: (_: String, _: String), file: StaticString = #file, line: UInt = #line) {
    if actual != expected {
      XCTFail("Expected \(expected) but was \(actual)", file: file, line: line)
    }
  }

}
