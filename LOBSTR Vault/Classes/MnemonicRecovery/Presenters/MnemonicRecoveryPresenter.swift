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
  func recoveryButtonWasPressed()
}

class MnemonicRecoveryPresenterImpl: MnemonicRecoveryPresenter {
  fileprivate weak var view: MnemonicRecoveryView?
  
  var mnemonic: String = ""
  var suggestionList: [String] = []
  let wordsNumberInMnemonic = 24
  
  let mnemonicManager: MnemonicManager
  
  init(view: MnemonicRecoveryView, mnemonicManager: MnemonicManager = MnemonicManagerImpl()) {
    self.view = view
    self.view?.displayRecoveryButton(isEnabled: true)
    self.mnemonicManager = mnemonicManager
  }
  
  // MARK: - MnemonicRecoveryPresenter
  
  func suggestionWordWasPressed(suggestionWord: String, text: String) {
    add(suggestionWord, to: text)
  }
  
  func textViewWasChanged(text: String) {
    clearSuggestionList()
    
    guard text.count > 0 else { return }
    
    mnemonic = text
    suggestionListRequest(by: text)
    highlightWrongWords(in: text)
  }
  
  func recoveryButtonWasPressed() {
    store(mnemonic: mnemonic)
    transitionToPinScreen()
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
  
  func transitionToPinScreen() {
    guard let pinViewController = PinViewController.createFromStoryboard()
    else { fatalError() }
    
    pinViewController.mode = .createPinFirstStep
    
    let mnemonicRecoveryViewController =
      view as! MnemonicRecoveryViewController
    mnemonicRecoveryViewController.navigationController?
      .pushViewController(pinViewController,
                          animated: true)
  }
}

private extension MnemonicRecoveryPresenterImpl {
  private func store(mnemonic: String) {
    _ = mnemonicManager.encryptAndStoreInKeychain(mnemonic: mnemonic)
  }
}
