import Foundation
@testable import LOBSTR_Vault

class MnemonicRecoveryViewSpy: MnemonicRecoveryView {
  func displayHighlightedWords(attributedStrings: NSMutableAttributedString) {
    
  }
  
  
  var displaySuggestionListWasCalled = false
  var updatedTextAfterPickingSuggestionWord = ""
  
  func displayRecoveryButton(isHidden: Bool) {
    
  }
  
  func displaySuggestionList(suggestionList: [String]) {
    displaySuggestionListWasCalled = true
  }
  
  func displayPickedWordFromSuggestionList(updatedText: String) {
    updatedTextAfterPickingSuggestionWord = updatedText
  }  
  
}
