@testable import LOBSTR_Vault
import XCTest

class MnemonicHelperTest: XCTestCase {
  override func setUp() {}
  
  func testWordListShouldBeReceivedFromString() {
    let str = "hello galaxy gallery game yellow"
    let expectedSeparatedWords = ["hello", "galaxy", "gallery", "game", "yellow"]
    
    let separatedWords = MnemonicHelper.getSeparatedWords(from: str)
    
    XCTAssertEqual(expectedSeparatedWords,
                   separatedWords, "Word list is expected to be received")
  }
  
  func testAutocopleteSuggestionsShouldBeReceivedFromMnemonicDictionary() {
    let userText = "hea"
    let expectedAutocompleteSuggestions = ["head", "health", "heart", "heavy"]
    
    let autocompleteSuggestions = MnemonicHelper.getAutocompleteSuggestions(userText: userText)
    
    XCTAssertEqual(expectedAutocompleteSuggestions, autocompleteSuggestions,
                   "Autocomplete suggestions are expected to be received")
  }
  
  func testWordShouldBeFoundInMnemonicDictionary() {
    let existingWord = "health"
    
    let searchingResult = MnemonicHelper.mnemonicWordIsExist(existingWord)
    
    XCTAssert(searchingResult, "The word is expected to be found")
  }
  
  func testSuggestionWordShouldBeAddedToText() {
    let expectedText = "hello galaxy gallery game yellow heart "
    let text = "hello galaxy gallery game yellow he"
    let suggestionWord = "heart"
    
    let updatedText = MnemonicHelper.addSuggestionWord(to: text, suggestionWord)
    
    XCTAssertEqual(expectedText, updatedText,
                   "The word is expected to be added to text with one space at the end")
  }
  
  func testHighlightedAttributedStringShouldBeReceived() {
    let highlightedWord = "heart"
    let text = "hello galaxy gallery game yellow heart"
    let highlightColor = UIColor.red
    let expectedHighlightedCharacterPositions = [33, 34, 35, 36, 37]
    var highlightedCharacterPositions: [Int] = []
    
    let attributedString = NSMutableAttributedString(string: text)
    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray,
                                  range: NSRange(location: 0, length: text.utf16.count))
    
    let result = MnemonicHelper.getHighlightedAttributedString(attributedString: attributedString,
                                                               word: highlightedWord,
                                                               in: text,
                                                               highlightColor: highlightColor)
    
    for item in 0..<text.utf16.count {
      let attributes = result.attributes(at: item, effectiveRange: nil)
      if attributes[NSAttributedString.Key.foregroundColor] as! UIColor == highlightColor {
        highlightedCharacterPositions.append(item)
      }
    }
    
    XCTAssertEqual(expectedHighlightedCharacterPositions, highlightedCharacterPositions,
                   "Highlighted attributed strings are expected to be received")
  }
  
  func testStringShouldBeReceivedFromSeparatedWords() {
    let words = ["hello", "galaxy", "gallery", "game", "yellow"]
    let expectedString = "hello, galaxy, gallery, game, yellow"
    
    let string = MnemonicHelper.getStringFromSeparatedWords(in: words)
    
    XCTAssertEqual(expectedString, string, "String is expected to be received from string array")
  }
}
