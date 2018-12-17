@testable import LOBSTR_Vault
import XCTest

class MnemonicVerificationPresenterTest: XCTestCase {
  let mnemonicVerificationViewSpy = MnemonicVerificationViewSpy()
  var mnemonicVerificationPresenter: MnemonicVerificationPresenterImpl!
  
  override func setUp() {
    super.setUp()
    
    mnemonicVerificationPresenter = MnemonicVerificationPresenterImpl()
    mnemonicVerificationPresenter.initData(view: mnemonicVerificationViewSpy)
  }
  
  func testShuffledMnemonicListShouldBeInitialized() {
    let generatedMnemonicList = ["hello", "galaxy", "gallery", "game", "yellow"]
    mnemonicVerificationPresenter.setGeneratedMnemonicList(generatedList: generatedMnemonicList)
    
    mnemonicVerificationPresenter.initShuffledMnemonicList()
    
    XCTAssertNotEqual(generatedMnemonicList, mnemonicVerificationPresenter.getShuffledMnemonicList,
                      "Shuffled mnemonic list is expected to be received")
    XCTAssert(mnemonicVerificationViewSpy.displayShuffledMnemonicListWasCalled,
              "Shuffled collectionView is expected to be updated")
  }
  
  func testShuffledMnemonicListShouldNotBeInitializedBecauseOfEmptyGeneratedMnemonicList() {
    mnemonicVerificationPresenter.setGeneratedMnemonicList(generatedList: [])
    
    mnemonicVerificationPresenter.initShuffledMnemonicList()
    
    XCTAssertEqual([], mnemonicVerificationPresenter.getShuffledMnemonicList,
                   "Shuffled mnemonic list is expected to be empty")
    XCTAssertFalse(mnemonicVerificationViewSpy.displayShuffledMnemonicListWasCalled,
                   "Shuffled mnemonic list isn't expected to be displayed")
  }
  
  func testShuffledWordShouldBeMoveToListForVerification() {
    let generatedMnemonicList = ["hello", "galaxy", "gallery", "game", "yellow"]
    mnemonicVerificationPresenter.setGeneratedMnemonicList(generatedList: generatedMnemonicList)
    let indexOfShuffledWord = 1
    let indexPath = IndexPath(item: indexOfShuffledWord, section: 0)
    
    mnemonicVerificationPresenter.initShuffledMnemonicList()
    mnemonicVerificationPresenter.moveShuffledWordToListForVerification(by: indexPath)
    
    XCTAssertEqual(mnemonicVerificationPresenter.getShuffledMnemonicList[indexOfShuffledWord], mnemonicVerificationPresenter.getMnemonicListForVerification[0],
                   "Shuffled word is expected to be moved to list for verification")
    XCTAssert(mnemonicVerificationViewSpy.shuffledCollectionViewWasUpdated,
              "Shuffled collection view is expected to be updated")
    XCTAssert(mnemonicVerificationViewSpy.collectionViewForVerificationWasUpdated,
              "Collection view for verification is expected to be updated")
  }
}
