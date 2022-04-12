import XCTest
import stellarsdk
@testable import LOBSTR_Vault

class TransactionHelperTests: XCTestCase {

  let pk = "GASB2IU6JPRCPUKMLRA6UJKMQ3HQOAL7F55M362JWSPYJVFHLR7HLQ4E"
  let sk = "SBPP5Z34PIVCVJPSLEQQDJEQ5MJ55TJNAZUVY7DXYFUC67Q7MT7PGBTG"
  
  let pk2 = "GBHQXJDYVMLKQZEWAFJN3OUZTDQS7A455X7OIPAILLPH2CRG73TFK2KM"
  let sk2 = "SBORO5K7YCTLNEFBTZVJT3RKNIZ345NTH37LF36TJDOXWNOXV3TRUPX3"
  
  func testSignatureShouldExistInTransactionXDRV1() throws {
    let xdr = "AAAAAgAAAABhfnCxEBdqRlFr7SHUfwuK4/dcmMWsaEcT0bkK+UyogQAAAGQBrIlSAAAHvAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAQAAAABhfnCxEBdqRlFr7SHUfwuK4/dcmMWsaEcT0bkK+UyogQAAAAAAAAAAAAST4AAAAAAAAAAB+UyogQAAAEC6dmu3b4qnjYE7r34Nrb/ElZplpSXx4aGR76Fj89MNqta+u4O0fFJjqBQnXbvMnnYhNWHCzuzYVJxLXeodszQJ"
    
    let publicKey = "GBQX44FRCALWURSRNPWSDVD7BOFOH524TDC2Y2CHCPI3SCXZJSUICCHC"
    
    let envelopeXDR = try! TransactionEnvelopeXDR(xdr: xdr)
    
    XCTAssertTrue(TransactionHelper.isThereVerifiedSignature(for: publicKey, in: envelopeXDR))
  }
  
  func testSignatureShouldExistInTransactionXDRV0() throws {
    let xdr = "AAAAACQdIp5L4ifRTFxB6iVMhs8HAX8ves37SbSfhNSnXH51AAAAZAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAABAAAAAE8LpHirFqhklgFS3bqZmOEvg53t/uQ8CFrefQom/uZVAAAAAAAAAAAAD0JAAAAAAAAAAAKnXH51AAAAQD13QW1d+5yypkiIZyTWynQ/rRBS8XrD/r0bd3CMUxML/Y9sF8IJpe5T4GQzRPBX1aVBvEHK/2tWCU9KLSuZ1wgm/uZVAAAAQJirw1Zlu73VeGIpGPZpXOTKafxhMa26WeJspvBhesDD/vG27lDj0nSLvO6FPrKEkGv6uNlRv3VXXPScOruU6Q0="
    
    let publicKey = "GASB2IU6JPRCPUKMLRA6UJKMQ3HQOAL7F55M362JWSPYJVFHLR7HLQ4E"
    let publicKey2 = "GBHQXJDYVMLKQZEWAFJN3OUZTDQS7A455X7OIPAILLPH2CRG73TFK2KM"
    
    let envelopeXDR = try! TransactionEnvelopeXDR(xdr: xdr)
    
    XCTAssertTrue(TransactionHelper.isThereVerifiedSignature(for: publicKey, in: envelopeXDR))
    XCTAssertTrue(TransactionHelper.isThereVerifiedSignature(for: publicKey2, in: envelopeXDR))
  }
  
  func testSignaturesV0TwoOperations() throws {
    let xdr = "AAAAAFc3+tplC+j/l2Dlu12+bhEwI75nrLdP1Tn/usnzhUKoAAAAyAGjXlEAAAAqAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAABAAAAAI3bxgX6nVnz8W2Cdz36gkTYisON4e5IX5/V0BhdsePAAAAAAAAAAAAAADAMAAAAAAAAAAEAAAAAjdvGBfqdWfPxbYJ3PfqCRNiKw43h7khfn9XQGF2x48AAAAAAAAAAAAX14QAAAAAAAAAAAfOFQqgAAABAlcaXDW7TKwp/l/Hu8KvA9kl0IeiHb5M19rAbYtx6nnVxTL2yz1B7T2CODKk/1XbPANNxwZlRQ4Fw32qCOGj9Cg=="
    
    let publicKey = "GBLTP6W2MUF6R74XMDS3WXN6NYITAI56M6WLOT6VHH73VSPTQVBKRQMN"
    
    let envelopeXDR = try! TransactionEnvelopeXDR(xdr: xdr)
    
    XCTAssertTrue(TransactionHelper.isThereVerifiedSignature(for: publicKey, in: envelopeXDR))
  }

  
  func testChallengeSignSuccess() {
//    let pk = "GDPU43WVN6BPAKCCGMRYEQNPZ2HLMBK6ZXKUF6O6OXI5HK7KPIFKO7CW"
    let seed = "SDLCAHQJ2CMFRNINHHDW4RPWWFMUBDMQHVW3B47LQGKDM3RSHP25OTFO"
    let keyPair = try! KeyPair(secretSeed: seed)
    
    let transaction = "AAAAAFc3+tplC+j/l2Dlu12+bhEwI75nrLdP1Tn/usnzhUKoAAAAyAGjXlEAAAAsAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAABAAAAAI3bxgX6nVnz8W2Cdz36gkTYisON4e5IX5/V0BhdsePAAAAAAAAAAAAAAH1kAAAAAAAAAAEAAAAAjdvGBfqdWfPxbYJ3PfqCRNiKw43h7khfn9XQGF2x48AAAAAAAAAAAAAAFFoAAAAAAAAAAfOFQqgAAABA6Lkt3li1xM+W+46kFyCAGhwdTe2i563AigTCVhNbplo+jssvLtaVFjdM8RgTlltL2maQazO1j6Ush+ePvpAYDA=="
      
    let transactionEnvelope2 = try! TransactionEnvelopeXDR(xdr: transaction)
    let transformedTransactionEnvelope = TransactionHelper.tryToTransformTransactionXDRV0ToV1(envelopeXDR: transactionEnvelope2)
    
    let txHash = try! [UInt8](transformedTransactionEnvelope.txHash(network: .public))
    transformedTransactionEnvelope.appendSignature(signature: keyPair.signDecorated(txHash))
    
    print(transformedTransactionEnvelope.xdrEncoded!)
    
    // Valid signatures for the same transaction XDR above from the Stellar laboratory.
    let validServerSignature = "YJwa2DTBYjlN1Jg3IcgEBFmXUuvh8MDzE3vy20Q8sItEy3xs218HRi+SvMq71sPh1uFZkZuFq/8G+rlmLeCYBw=="
    let validUserSignature = "hvE1lIC+dekEDpMpmVPk3NvsgO6ocGKUZrlIdsWlL33mT4IUkepEonLpXP1sdWNKI25M9bD63FTNpEVziHvNAQ=="
    
    let serverSignature = transformedTransactionEnvelope.txSignatures[0].signature.base64EncodedString()
    let userSignature = transformedTransactionEnvelope.txSignatures[1].signature.base64EncodedString()
            
    XCTAssertEqual(validServerSignature, serverSignature)
    XCTAssertEqual(validUserSignature, userSignature)
  }
  
  func testTransactionV1Sign() throws {
    let keyPair = try! KeyPair(secretSeed: "SB2VUAO2O2GLVUQOY46ZDAF3SGWXOKTY27FYWGZCSV26S24VZ6TUKHGE")
    // transaction envelope v1
    let xdr = "AAAAAgAAAADUtWEQOb8u8wqHpML1OV4SV3E5EjliNElgRW2AmJDkaQAAJxAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAEAAAAA1LVhEDm/LvMKh6TC9TleEldxORI5YjRJYEVtgJiQ5GkAAAABAAAAANS1YRA5vy7zCoekwvU5XhJXcTkSOWI0SWBFbYCYkORpAAAAAAAAAAAAAAABAAAAAAAAAAA="
    
    var envelopeXDR = TransactionHelper.tryToTransformTransactionXDRV0ToV1(envelopeXDR: try! TransactionEnvelopeXDR(xdr: xdr))
    
    try! TransactionHelper.signTransaction(transactionEnvelopeXDR: &envelopeXDR, userKeyPair: keyPair)
      
    let userSignature = envelopeXDR.txSignatures.first!.signature.base64EncodedString()
    let validUserSignature = "1iw8QognbB+8DmvUTAk0SQSxjpsYqa2pnP9/A7qJwyJ5IPVG+wl4w6M5mHel5CjzsnWKwurE/LCY26Jmz5KiBw=="
        
    print("XDR Envelope: \(envelopeXDR.xdrEncoded!)")
    XCTAssertEqual(validUserSignature, userSignature)
  }
  
  func testTransactionV0SignWithTwoOperations() throws {
    let keyPair = try! KeyPair(secretSeed: "SB2VUAO2O2GLVUQOY46ZDAF3SGWXOKTY27FYWGZCSV26S24VZ6TUKHGE")
    // transaction envelope v0 with two payment operations
    let xdr = "AAAAANS1YRA5vy7zCoekwvU5XhJXcTkSOWI0SWBFbYCYkORpAAAAyAAAAAAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAABAAAAAE8LpHirFqhklgFS3bqZmOEvg53t/uQ8CFrefQom/uZVAAAAAAAAAAAF9eEAAAAAAAAAAAEAAAAATwukeKsWqGSWAVLdupmY4S+Dne3+5DwIWt59Cib+5lUAAAAAAAAAAAL68IAAAAAAAAAAAA=="
    
    let envelopeXDR = TransactionHelper.tryToTransformTransactionXDRV0ToV1(envelopeXDR: try! TransactionEnvelopeXDR(xdr: xdr))
    
    let txHash = try! [UInt8](envelopeXDR.txHash(network: .public))
    envelopeXDR.appendSignature(signature: keyPair.signDecorated(txHash))
      
    let userSignature = envelopeXDR.txSignatures.first!.signature.base64EncodedString()
    let validUserSignature = "/x+ipnunmfDID9kX09bmnZOLSG/3Cwld0zgHzpgN6vNAQ4ebrcnALv8hwvVlS5IFY6wKRacWBM0gA9eSd68/CQ=="
        
    print("XDR Envelope: \(envelopeXDR.xdrEncoded!)")
    XCTAssertEqual(validUserSignature, userSignature)
  }
    
  func testAllOperationsListNamesShouldBeRecevied() throws {
    let xdr = "AAAAACQdIp5L4ifRTFxB6iVMhs8HAX8ves37SbSfhNSnXH51AAACWAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABgAAAAAAAAAAAAAAAE8LpHirFqhklgFS3bqZmOEvg53t/uQ8CFrefQom/uZVAAAAAAExLQAAAAAAAAAAAQAAAABPC6R4qxaoZJYBUt26mZjhL4Od7f7kPAha3n0KJv7mVQAAAAAAAAAABfXhAAAAAAAAAAANAAAAAAAAAAA7msoAAAAAAE8LpHirFqhklgFS3bqZmOEvg53t/uQ8CFrefQom/uZVAAAAAUJUQwAAAAAA6KYahh5gr2D4B3PgY0blxyy+Wdyt2jdgjVjvQlEdn9wAAAAAAJiWgAAAAAAAAAAAAAAAAwAAAAAAAAABQlRDAAAAAADophqGHmCvYPgHc+BjRuXHLL5Z3K3aN2CNWO9CUR2f3AAAAAJUC+QAAAAACgAAAAEAAAAAAAAAAAAAAAAAAAAMAAAAAUJUQwAAAAAA6KYahh5gr2D4B3PgY0blxyy+Wdyt2jdgjVjvQlEdn9wAAAAAAAAABKgXyAAAAADwAAAAAQAAAAAAAAAAAAAAAAAAAAUAAAAAAAAAAAAAAAAAAAABAAAACgAAAAEAAAACAAAAAQAAAAYAAAABAAAACgAAAAAAAAAAAAAAAAAAAAA="
    let expectedOperationNames = ["Create Account", "Payment", "Path Payment Strict Send", "Sell Offer", "Buy Offer", "Set Options"]
    
    let transactionXDR = try! TransactionEnvelopeXDR(xdr: xdr)
    let operationNames = try TransactionHelper.getListOfOperationNames(from: transactionXDR, transactionType: nil)
    
    XCTAssertEqual(expectedOperationNames, operationNames, "Expected to receive list of operation names")
  }
  
  func testListOfOperationNamesShouldBeRecevied() throws {
    let xdr = "AAAAAI3bxgX6nVnz8W2Cdz36gkTYisON4e5IX5/V0BhdsePAAAAAyAFIyE8AAAAJAAAAAAAAAAAAAAACAAAAAAAAAAEAAAAAq4beUlPpxLFRF2ciNPPNUlULKae/kplLgE8MTCTMwVAAAAAAAAAAANCdwwAAAAAAAAAABQAAAAAAAAAAAAAAAAAAAAEAAAAUAAAAAQAAAAUAAAABAAAABQAAAAEAAAAFAAAAAAAAAAAAAAAAAAAAAV2x48AAAABAvQgSWvqVkVRfzVlFgCEq1BHlij1nWhLjghq9IwRV3S/ruJxzJkle3esf9AE2INQatFqCHtJYzE/4uelK6CxeCw=="
    let expectedOperationNames = ["Payment", "Set Options"]
    
    let transactionXDR = try! TransactionEnvelopeXDR(xdr: xdr)
    let operationNames = try TransactionHelper.getListOfOperationNames(from: transactionXDR, transactionType: nil)
    
    XCTAssertEqual(expectedOperationNames, operationNames, "Expected to receive list of operation names")
  }
  
  
  func testListOfOperationNamesV1ShouldBeRecevied() throws {
    let xdr = "AAAAAgAAAABXN/raZQvo/5dg5btdvm4RMCO+Z6y3T9U5/7rJ84VCqAAAJxABo15RAAAAIAAAAAAAAAAAAAAAAQAAAAEAAAAAVzf62mUL6P+XYOW7Xb5uETAjvmest0/VOf+6yfOFQqgAAAAGAAAAAUJUQwAAAAAAKTpjGpnWX8jImMrLprg+1nHJhiAVINNe+zSvg3bvNiUAAAAAAAAAAAAAAAAAAAAB84VCqAAAAEAiFfMV4y/pTQWeKiMm4Qy2Cy8ituKV+YQu5z1Y0hTc2UJUqOzKJqTBiH8jEA1p3Oogm7zr9VEg/AxrQBYi7zsN"
    let expectedOperationNames = ["Change Trust"]
    
    let transactionXDR = try! TransactionEnvelopeXDR(xdr: xdr)
    let operationNames = try TransactionHelper.getListOfOperationNames(from: transactionXDR, transactionType: nil)
    
    XCTAssertEqual(expectedOperationNames, operationNames, "Expected to receive list of operation names")
  }
  
  
  func testPaymentOperation() {
    let xdr = "AAAAACQdIp5L4ifRTFxB6iVMhs8HAX8ves37SbSfhNSnXH51AAAAZAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAABAAAAAE8LpHirFqhklgFS3bqZmOEvg53t/uQ8CFrefQom/uZVAAAAAAAAAACDIVYAAAAAAAAAAAA="
    
    let expectedNamesAndValues = [("Amount", "220"),
                                  ("Asset", "XLM"),
                                  ("Destination", pk2.getTruncatedPublicKey())]
            
    let paymentOperation = try! TransactionHelper.getOperation(from: xdr)
    let namesAndValues = TransactionHelper.parseOperation(from: paymentOperation, memo: "", created: "")
    
    if expectedNamesAndValues.count != namesAndValues.count {
      XCTFail("Number of expected values don't equal with a number of actual values")
      return
    }
    
    for (index, expectedItem) in expectedNamesAndValues.enumerated() {
      assertStringPairsEqual(actual: namesAndValues[index], expected: expectedItem)
    }
  }
  
  func testCreateAccountOperation() {
    let xdr = "AAAAACQdIp5L4ifRTFxB6iVMhs8HAX8ves37SbSfhNSnXH51AAAAZAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAE8LpHirFqhklgFS3bqZmOEvg53t/uQ8CFrefQom/uZVAAAAAAX14QAAAAAAAAAAAA=="
    
    let expectedNamesAndValues = [("Destination", pk2.getTruncatedPublicKey()),
                                  ("Starting Balance", "10")]
            
    let createAccountOperation = try! TransactionHelper.getOperation(from: xdr)
    let namesAndValues = TransactionHelper.parseOperation(from: createAccountOperation, memo: "", created: "")
    
    if expectedNamesAndValues.count != namesAndValues.count {
      XCTFail("Number of expected values don't equal with a number of actual values")
      return
    }
    
    for (index, expectedItem) in expectedNamesAndValues.enumerated() {
      assertStringPairsEqual(actual: namesAndValues[index], expected: expectedItem)
    }
  }
  
  func testPathPaymentStrictSendOperation() {
    let xdr = "AAAAACQdIp5L4ifRTFxB6iVMhs8HAX8ves37SbSfhNSnXH51AAAAZAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAANAAAAAVVTRAAAAAAA6KYahh5gr2D4B3PgY0blxyy+Wdyt2jdgjVjvQlEdn9wAAAAAR4aMAAAAAABPC6R4qxaoZJYBUt26mZjhL4Od7f7kPAha3n0KJv7mVQAAAAFFVVJUAAAAAB/Vkm6vsIJ7WAM76Uxga+I3fyUYTSadMEYMZUmOyA7nAAAAAC+vCAAAAAABAAAAAAAAAAAAAAAA"
    
    let expectedNamesAndValues = [("Destination", pk2.getTruncatedPublicKey()),
                                  ("Send Asset", "USD"),
                                  ("Send Asset Issuer", "GDUKMGUG...DWP5YLEX"),
                                  ("Send Amount", "120"),
                                  ("Destination Asset", "EURT"),
                                  ("Destination Issuer", "GAP5LETO...ZAHOOS2S"),
                                  ("Destination Min", "80")]
            
    let pathPaymentStrictSendOperation = try! TransactionHelper.getOperation(from: xdr)
    let namesAndValues = TransactionHelper.parseOperation(from: pathPaymentStrictSendOperation, memo: "", created: "")
    
    if expectedNamesAndValues.count != namesAndValues.count {
      XCTFail("Number of expected values don't equal with a number of actual values")
      return
    }
    
    for (index, expectedItem) in expectedNamesAndValues.enumerated() {
      assertStringPairsEqual(actual: namesAndValues[index], expected: expectedItem)
    }
  }
  
  func testPathPaymentStricktReceiveOperation() {
    let xdr = "AAAAACQdIp5L4ifRTFxB6iVMhs8HAX8ves37SbSfhNSnXH51AAAAZAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAACAAAAAAAAADo1KUQAAAAAAE8LpHirFqhklgFS3bqZmOEvg53t/uQ8CFrefQom/uZVAAAAAUJUQwAAAAAAKTpjGpnWX8jImMrLprg+1nHJhiAVINNe+zSvg3bvNiUAAAAAAAehIAAAAAAAAAAAAAAAAA=="
    
    let expectedNamesAndValues = [("Destination", pk2.getTruncatedPublicKey()),
                                  ("Send Asset", "XLM"),
                                  ("Send Amount", "25000"),
                                  ("Destination Asset", "BTC"),
                                  ("Destination Issuer", "GAUTUYY2...543CKUEF"),
                                  ("Destination Min", "0.05")]
            
    let pathPaymentStrictSendOperation = try! TransactionHelper.getOperation(from: xdr)
    let namesAndValues = TransactionHelper.parseOperation(from: pathPaymentStrictSendOperation, memo: "", created: "")
    
    if expectedNamesAndValues.count != namesAndValues.count {
      XCTFail("Number of expected values don't equal with a number of actual values")
      return
    }
    
    for (index, expectedItem) in expectedNamesAndValues.enumerated() {
      assertStringPairsEqual(actual: namesAndValues[index], expected: expectedItem)
    }
  }
  
  func testManageSellOfferOperation() {
    let xdr = "AAAAACQdIp5L4ifRTFxB6iVMhs8HAX8ves37SbSfhNSnXH51AAAAZAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAFCVEMAAAAAACk6YxqZ1l/IyJjKy6a4PtZxyYYgFSDTXvs0r4N27zYlAAAAN+EdYAAAAAATAExLQAAAAAAAAAAAAAAAAAAAAAA="

    let expectedNamesAndValues = [("Selling", "XLM"),
                                 ("Buying", "BTC"),
                                 ("Amount", "24000"),
                                 ("Price", "0.0000038")]
           
    let manageSellOfferOperation = try! TransactionHelper.getOperation(from: xdr)
    let namesAndValues = TransactionHelper.parseOperation(from: manageSellOfferOperation, memo: "", created: "")

    if expectedNamesAndValues.count != namesAndValues.count {
     XCTFail("Number of expected values don't equal with a number of actual values")
     return
    }

    for (index, expectedItem) in expectedNamesAndValues.enumerated() {
     assertStringPairsEqual(actual: namesAndValues[index], expected: expectedItem)
    }
  }
  
  func testManageBuyOfferOperation() {
    let xdr = "AAAAACQdIp5L4ifRTFxB6iVMhs8HAX8ves37SbSfhNSnXH51AAAAZAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAMAAAAAUJUQwAAAAAAKTpjGpnWX8jImMrLprg+1nHJhiAVINNe+zSvg3bvNiUAAAABVVNEAAAAAADophqGHmCvYPgHc+BjRuXHLL5Z3K3aN2CNWO9CUR2f3AAAAA34R1gAAAAALQAAAAQAAAAAAAAAAAAAAAAAAAAA"
    
    let expectedNamesAndValues = [("Selling", "BTC"),
                                  ("Buying", "USD"),
                                  ("Amount", "6000"),
                                  ("Price", "11.25")]
            
    let manageBuyOfferOperation = try! TransactionHelper.getOperation(from: xdr)
    let namesAndValues = TransactionHelper.parseOperation(from: manageBuyOfferOperation, memo: "", created: "")
    
    if expectedNamesAndValues.count != namesAndValues.count {
      XCTFail("Number of expected values don't equal with a number of actual values")
      return
    }
    
    for (index, expectedItem) in expectedNamesAndValues.enumerated() {
      assertStringPairsEqual(actual: namesAndValues[index], expected: expectedItem)
    }
  }
  
  func testSetOptionsOperation() {
    let xdr = "AAAAACQdIp5L4ifRTFxB6iVMhs8HAX8ves37SbSfhNSnXH51AAAAZAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAEAAAADAAAAAQAAAAcAAAABAAAAHgAAAAEAAAAKAAAAAQAAABQAAAABAAAAKAAAAAEAAAAJbG9ic3RyLmNvAAAAAAAAAQAAAABPC6R4qxaoZJYBUt26mZjhL4Od7f7kPAha3n0KJv7mVQAAABQAAAAAAAAAAA=="
    
    let expectedNamesAndValues = [("Home Domain", "lobstr.co"),
                                  ("Master Weight", "30"),
                                  ("Low Threshold", "10"),
                                  ("Medium Threshold", "20"),
                                  ("High threshold", "40"),
                                  ("Signer Weight", "20")]
            
    let setOptionsOperation = try! TransactionHelper.getOperation(from: xdr)
    let namesAndValues = TransactionHelper.parseOperation(from: setOptionsOperation, memo: "", created: "")
    
    if expectedNamesAndValues.count != namesAndValues.count {
      XCTFail("Number of expected values don't equal with a number of actual values")
      return
    }
    
    for (index, expectedItem) in expectedNamesAndValues.enumerated() {
      assertStringPairsEqual(actual: namesAndValues[index], expected: expectedItem)
    }
  }
  
  func testAllowTrustOperation() {
    let xdr = "AAAAACQdIp5L4ifRTFxB6iVMhs8HAX8ves37SbSfhNSnXH51AAAAZAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAHAAAAAOimGoYeYK9g+Adz4GNG5ccsvlncrdo3YI1Y70JRHZ/cAAAAAVVTRAAAAAABAAAAAAAAAAA="
    
    let expectedNamesAndValues = [("Asset", "USD"),
                                  ("Trustor", "GDUKMGUG...DWP5YLEX"),
                                  ("Authorize", "1")]
            
    let allowTrustOperation = try! TransactionHelper.getOperation(from: xdr)
    let namesAndValues = TransactionHelper.parseOperation(from: allowTrustOperation, memo: "", created: "")
    
    if expectedNamesAndValues.count != namesAndValues.count {
      XCTFail("Number of expected values don't equal with a number of actual values")
      return
    }
    
    for (index, expectedItem) in expectedNamesAndValues.enumerated() {
      assertStringPairsEqual(actual: namesAndValues[index], expected: expectedItem)
    }
  }
  
  func testChangeTrustOperation() {
    let xdr = "AAAAACQdIp5L4ifRTFxB6iVMhs8HAX8ves37SbSfhNSnXH51AAAAZAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAGAAAAAUJUQwAAAAAAKTpjGpnWX8jImMrLprg+1nHJhiAVINNe+zSvg3bvNiUAAAAAAAAAAAAAAAAAAAAA"
    
    let expectedNamesAndValues = [("Asset", "BTC"),
                                  ("Issuer", "GAUTUYY2...543CKUEF"),
                                  ("Limit", "0")]
            
    let changeTrustOperation = try! TransactionHelper.getOperation(from: xdr)
    let namesAndValues = TransactionHelper.parseOperation(from: changeTrustOperation, memo: "", created: "")
    
    if expectedNamesAndValues.count != namesAndValues.count {
      XCTFail("Number of expected values don't equal with a number of actual values")
      return
    }
    
    for (index, expectedItem) in expectedNamesAndValues.enumerated() {
      assertStringPairsEqual(actual: namesAndValues[index], expected: expectedItem)
    }
  }
  
  func testAccountMergeOperation() {
    let xdr = "AAAAACQdIp5L4ifRTFxB6iVMhs8HAX8ves37SbSfhNSnXH51AAAAZAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAIAAAAAE8LpHirFqhklgFS3bqZmOEvg53t/uQ8CFrefQom/uZVAAAAAAAAAAA="
    
    let expectedNamesAndValues = [("Destination", pk2.getTruncatedPublicKey())]
            
    let accountMergeOperation = try! TransactionHelper.getOperation(from: xdr)
    let namesAndValues = TransactionHelper.parseOperation(from: accountMergeOperation, memo: "", created: "")
    
    if expectedNamesAndValues.count != namesAndValues.count {
      XCTFail("Number of expected values don't equal with a number of actual values")
      return
    }
    
    for (index, expectedItem) in expectedNamesAndValues.enumerated() {
      assertStringPairsEqual(actual: namesAndValues[index], expected: expectedItem)
    }
  }
  
  func testManageDataOperation() {
    let xdr = "AAAAACQdIp5L4ifRTFxB6iVMhs8HAX8ves37SbSfhNSnXH51AAAAZAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAKAAAACmVudHJ5X25hbWUAAAAAAAEAAAALZW50cnlfdmFsdWUAAAAAAAAAAAA="
    
    let expectedNamesAndValues = [("Name", "entry_name"),
                                  ("Value", "entry_value")]
            
    let manageDataOperation = try! TransactionHelper.getOperation(from: xdr)
    let namesAndValues = TransactionHelper.parseOperation(from: manageDataOperation, memo: "", created: "")
    
    if expectedNamesAndValues.count != namesAndValues.count {
      XCTFail("Number of expected values don't equal with a number of actual values")
      return
    }
    
    for (index, expectedItem) in expectedNamesAndValues.enumerated() {
      assertStringPairsEqual(actual: namesAndValues[index], expected: expectedItem)
    }
  }
  
  func testBumpSequenceOperation() {
    let xdr = "AAAAACQdIp5L4ifRTFxB6iVMhs8HAX8ves37SbSfhNSnXH51AAAAZAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAALAAAAAAF5QegAAAAAAAAAAA=="
    
    let expectedNamesAndValues = [("Bump To", "24723944")]
            
    let bumpSequenceOperation = try! TransactionHelper.getOperation(from: xdr)
    let namesAndValues = TransactionHelper.parseOperation(from: bumpSequenceOperation, memo: "", created: "")
    
    if expectedNamesAndValues.count != namesAndValues.count {
      XCTFail("Number of expected values don't equal with a number of actual values")
      return
    }
    
    for (index, expectedItem) in expectedNamesAndValues.enumerated() {
      assertStringPairsEqual(actual: namesAndValues[index], expected: expectedItem)
    }
  }
  
  func testValidatedDateShouldBeReceived() {
    let date = "2018-12-27T13:54:52.137904Z"
    let expectedDate = "Dec 27, 2018, 16:54"
    
    let newDate = TransactionHelper.getValidatedDate(from: date)
    
    XCTAssertEqual(expectedDate, newDate, "Expected to receive validate date")
  }
  
  func testOperationShouldBeReceviedByIndexFromXDR() throws {
    let accountId = "GCVYNXSSKPU4JMKRC5TSENHTZVJFKCZJU67ZFGKLQBHQYTBEZTAVB5QN"
    let operationIndex = 0
    let xdr = "AAAAAI3bxgX6nVnz8W2Cdz36gkTYisON4e5IX5/V0BhdsePAAAAAyAFIyE8AAAAJAAAAAAAAAAAAAAACAAAAAAAAAAEAAAAAq4beUlPpxLFRF2ciNPPNUlULKae/kplLgE8MTCTMwVAAAAAAAAAAANCdwwAAAAAAAAAABQAAAAAAAAAAAAAAAAAAAAEAAAAUAAAAAQAAAAUAAAABAAAABQAAAAEAAAAFAAAAAAAAAAAAAAAAAAAAAV2x48AAAABAvQgSWvqVkVRfzVlFgCEq1BHlij1nWhLjghq9IwRV3S/ruJxzJkle3esf9AE2INQatFqCHtJYzE/4uelK6CxeCw=="
    
    let paymentOperation = try PaymentOperation(sourceAccountId: nil,
                                                destinationAccountId: KeyPair(accountId: accountId).accountId,
                                                asset: Asset.init(type: AssetType.ASSET_TYPE_NATIVE, code: nil, issuer: nil)!,
                                                amount: Decimal(string: "350")!)
    
    let operation = try TransactionHelper.getOperation(from: xdr, by: operationIndex) as? PaymentOperation
    
    XCTAssertEqual(paymentOperation.amount, operation?.amount, "Expected to receive amount of payment operation")
    XCTAssertEqual(paymentOperation.asset.type, operation?.asset.type, "Expected to receive asset type of payment operation")
    XCTAssertEqual(paymentOperation.destinationAccountId, operation?.destinationAccountId, "Expected to receive destination account id of payment operation")
  }
  
  func testInvalidaTransactionErrorShouldBeReceivedWhileGettingOperationByIndex() {
    let xdr = "wrong xdr"
    let operationIndex = 0
    
    XCTAssertThrowsError(try TransactionHelper.getOperation(from: xdr, by: operationIndex)) { error in
      XCTAssertEqual(error as? VaultError.TransactionError, VaultError.TransactionError.invalidTransaction, "Expected to receive invalid transaction error")
    }
  }
  
  func testOutOfOperationRangeErrorShouldBeReceivedWhileGettingOperationByIndex() {
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
