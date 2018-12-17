import Foundation
import UIKit

protocol MnemonicRecoveryView: class {
  func displayRecoveryButton(isEnabled: Bool)
  func displaySuggestionList(suggestionList: [String])
  func displayPickedWordFromSuggestionList(updatedText: String)
  func displayHighlightedWords(attributedStrings: [NSMutableAttributedString])
}

protocol MnemonicRecoveryPresenter {
  func suggestionWordWasPressed(suggestionWord: String, text: String)
  func textViewWasChanged(text: String)
}

class MnemonicRecoveryPresenterImpl: MnemonicRecoveryPresenter {
  fileprivate weak var view: MnemonicRecoveryView?
  
  var suggestionList: [String] = []
  let wordsNumberInMnemonic = 24
  
  init(view: MnemonicRecoveryView) {
    self.view = view
    self.view?.displayRecoveryButton(isEnabled: false)
  }
  
  // MARK: - MnemonicRecoveryPresenter
  
  func suggestionWordWasPressed(suggestionWord: String, text: String) {
    add(suggestionWord, to: text)
  }
  
  func textViewWasChanged(text: String) {
    clearSuggestionList()
    
    guard text.count > 0 else { return }
    
    suggestionListRequest(by: text)
    highlightWrongWords(in: text)
  }
  
  // MARK: - Public Methods
  
  func add(_ suggestionWord: String, to text: String) {
    let updatedText = MnemonicHelper.addSuggestionWord(to: text, suggestionWord)
    view?.displayPickedWordFromSuggestionList(updatedText: updatedText)
    clearSuggestionList()
    highlightWrongWords(in: updatedText)
  }
  
  func clearSuggestionList() {
    suggestionList.removeAll()
    view?.displaySuggestionList(suggestionList: suggestionList)
  }
  
  func suggestionListRequest(by subString: String) {
    if let lastWord = MnemonicHelper.getSeparatedWords(from: String(subString)).last {
      suggestionList.append(contentsOf: MnemonicHelper.getAutocompleteSuggestions(userText: lastWord))
    }
    
    view?.displaySuggestionList(suggestionList: suggestionList)
  }
  
  func highlightWrongWords(in string: String) {
    var attributedString = NSMutableAttributedString(string: string)
    let listOfSeparatedWords = MnemonicHelper.getSeparatedWords(from: string)
    
    for word in listOfSeparatedWords {
      if !MnemonicHelper.mnemonicWordIsExist(word) {
        attributedString = MnemonicHelper.getHighlightedAttributedString(attributedString: attributedString,
                                                                         word: word,
                                                                         in: string,
                                                                         highlightColor: UIColor.red)
      }
    }
    
    view?.displayHighlightedWords(attributedStrings: [attributedString])
  }
}
