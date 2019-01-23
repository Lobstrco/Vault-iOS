@testable import LOBSTR_Vault
import XCTest

class MnemonicRecoveryPresenterTest: XCTestCase {
  let mnemonicRecoveryViewSpy = MnemonicRecoveryViewSpy()
  var mnemonicRecoveryPresenter: MnemonicRecoveryPresenterImpl!
  
  override func setUp() {
    super.setUp()
    mnemonicRecoveryPresenter = MnemonicRecoveryPresenterImpl(view: mnemonicRecoveryViewSpy)
  }
  
  func testSuggestionListShouldBeCleared() {
    let expectedSuggestionNumberInList = 0
    mnemonicRecoveryPresenter.suggestionList = ["hello", "table", "tackle"]
    
    mnemonicRecoveryPresenter.clearSuggestionList()
    
    XCTAssertEqual(expectedSuggestionNumberInList,
                   mnemonicRecoveryPresenter.suggestionList.count,
                   "expected to the empty suggestion list")
    XCTAssert(mnemonicRecoveryViewSpy.displaySuggestionListWasCalled,
              "Expected to display the suggestion list")
  }
  
  func testSuggestionListShouldBeRecieved() {
    let expectedAutocompleteSuggestions = ["collect", "color", "column"]
    let userText = "col"
    
    mnemonicRecoveryPresenter.suggestionListRequest(by: userText)
    
    XCTAssertEqual(expectedAutocompleteSuggestions,
                   mnemonicRecoveryPresenter.suggestionList,
                   "Expected to receive the suggestion lists")
    XCTAssert(mnemonicRecoveryViewSpy.displaySuggestionListWasCalled,
              "Expected to display the suggestion list ")
  }
  
  func testSuggestionWordShouldBeAddedToText() {
    let suggestionWord = "collect"
    let text = "color column col"
    let expectedUpdateText = "color column collect "
    let expectedSuggestionNumberInList = 0
    
    mnemonicRecoveryPresenter.add(suggestionWord, to: text)
    
    XCTAssertEqual(expectedUpdateText,
                   mnemonicRecoveryViewSpy.updatedTextAfterPickingSuggestionWord,
                   "Expected to update the text")
    XCTAssertEqual(expectedSuggestionNumberInList,
                   mnemonicRecoveryPresenter.suggestionList.count,
                   "Expected to the empty suggestion list")
  }
}
