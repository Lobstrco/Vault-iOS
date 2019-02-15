@testable import LOBSTR_Vault
import XCTest

class MnemonicVerificationPresenterTest: XCTestCase {
  let mnemonicVerificationViewSpy = MnemonicVerificationViewSpy()
  var mnemonicVerificationPresenter: MnemonicVerificationPresenterImpl!
  
  override func setUp() {
    super.setUp()
    
    mnemonicVerificationPresenter = MnemonicVerificationPresenterImpl(view: mnemonicVerificationViewSpy)
  }
  
  func testShuffledMnemonicListShouldBeInitialized() {
    let generatedMnemonicList = ["hello", "galaxy", "gallery", "game", "yellow"]
    mnemonicVerificationPresenter.setGeneratedMnemonicList(generatedList: generatedMnemonicList)
    
    mnemonicVerificationPresenter.initShuffledMnemonicList()
    
    XCTAssertNotEqual(generatedMnemonicList, mnemonicVerificationPresenter.getShuffledMnemonicList,
                      "Expected to receive shuffled mnemonic list")
    XCTAssert(mnemonicVerificationViewSpy.displayShuffledMnemonicListWasCalled,
              "Expected to update shuffled mnemonic list")
  }
  
  func testShuffledMnemonicListShouldNotBeInitializedBecauseOfEmptyGeneratedMnemonicList() {
    mnemonicVerificationPresenter.setGeneratedMnemonicList(generatedList: [])
    
    mnemonicVerificationPresenter.initShuffledMnemonicList()
    
    XCTAssertEqual([], mnemonicVerificationPresenter.getShuffledMnemonicList,
                   "Expected to an empty shuffled mnemonic list")
    XCTAssertFalse(mnemonicVerificationViewSpy.displayShuffledMnemonicListWasCalled,
                   "Didn't expect to display shuffled mnemonic list")
  }
  
  func testShuffledWordShouldBeMoveToListForVerification() {
    let generatedMnemonicList = ["hello", "galaxy", "gallery", "game", "yellow"]
    mnemonicVerificationPresenter.setGeneratedMnemonicList(generatedList: generatedMnemonicList)
    let indexOfShuffledWord = 1
    let indexPath = IndexPath(item: indexOfShuffledWord, section: 0)
    
    mnemonicVerificationPresenter.initShuffledMnemonicList()
    mnemonicVerificationPresenter.moveShuffledWordToListForVerification(by: indexPath)
    
    XCTAssertEqual(mnemonicVerificationPresenter.getShuffledMnemonicList[indexOfShuffledWord], mnemonicVerificationPresenter.getMnemonicListForVerification[0],
                   "Expected to move shuffled word to list for verification")
    XCTAssert(mnemonicVerificationViewSpy.collectionViewForVerificationWasUpdated,
              "Expected to update collection view for verification")
  }
}
