import Foundation
@testable import LOBSTR_Vault

class MnemonicRecoveryViewSpy: MnemonicRecoveryView {
  
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
  
  func setHighlightTextView(isEnabled: Bool) {
    
  }
  
  func displayHighlightedWords(attributedStrings: NSMutableAttributedString) {
    
  }
  
}
