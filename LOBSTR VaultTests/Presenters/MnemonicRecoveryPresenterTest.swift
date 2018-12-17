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
    
    XCTAssertEqual(expectedSuggestionNumberInList, mnemonicRecoveryPresenter.suggestionList.count,
                   "The suggestion list is expected to be empty")
    XCTAssert(mnemonicRecoveryViewSpy.displaySuggestionListWasCalled,
              "The suggestion list is expected to be displayed")
  }
  
  func testSuggestionListShouldBeRecieved() {
    let expectedAutocompleteSuggestions = ["collect", "color", "column"]
    let userText = "col"
    
    mnemonicRecoveryPresenter.suggestionListRequest(by: userText)
    
    XCTAssertEqual(expectedAutocompleteSuggestions, mnemonicRecoveryPresenter.suggestionList,
                   "The suggestion lists are expected to be recieved")
    XCTAssert(mnemonicRecoveryViewSpy.displaySuggestionListWasCalled,
              "The suggestion list is expected to be displayed")
  }
  
  func testSuggestionWordShouldBeAddedToText() {
    let suggestionWord = "collect"
    let text = "color column col"
    let expectedUpdateText = "color column collect "
    let expectedSuggestionNumberInList = 0
    
    mnemonicRecoveryPresenter.add(suggestionWord, to: text)
    
    XCTAssertEqual(expectedUpdateText, mnemonicRecoveryViewSpy.updatedTextAfterPickingSuggestionWord,
                   "The text is expected to be updated")
    XCTAssertEqual(expectedSuggestionNumberInList, mnemonicRecoveryPresenter.suggestionList.count,
                   "The suggestion list is expected to be empty")
  }
}
