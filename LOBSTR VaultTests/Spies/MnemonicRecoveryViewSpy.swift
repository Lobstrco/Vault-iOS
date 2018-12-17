import Foundation
@testable import LOBSTR_Vault

class MnemonicRecoveryViewSpy: MnemonicRecoveryView {
  
  var displaySuggestionListWasCalled = false
  var updatedTextAfterPickingSuggestionWord = ""
  
  func displayRecoveryButton(isEnabled: Bool) {
    
  }
  
  func displaySuggestionList(suggestionList: [String]) {
    displaySuggestionListWasCalled = true
  }
  
  func displayPickedWordFromSuggestionList(updatedText: String) {
    updatedTextAfterPickingSuggestionWord = updatedText
  }
  
  func displayHighlightedWords(attributedStrings: [NSMutableAttributedString]) {
    
  }
  
  
}
