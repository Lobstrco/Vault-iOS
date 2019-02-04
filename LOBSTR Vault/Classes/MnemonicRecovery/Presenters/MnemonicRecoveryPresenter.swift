import Foundation

protocol MnemonicRecoveryView: class {
  func displayRecoveryButton(isHidden: Bool)
  func setHighlightTextView(isEnabled: Bool)
  func displaySuggestionList(suggestionList: [String])
  func displayPickedWordFromSuggestionList(updatedText: String)
  func displayHighlightedWords(attributedStrings: NSMutableAttributedString)
}

protocol MnemonicRecoveryPresenter {
  func suggestionWordWasPressed(suggestionWord: String, text: String)
  func textViewWasChanged(text: String)
  func recoveryButtonWasPressed()
}

class MnemonicRecoveryPresenterImpl {
  fileprivate weak var view: MnemonicRecoveryView?
  
  var mnemonic: String = ""
  var suggestionList: [String] = []
  let wordsNumberInMnemonic = 12
  
  let mnemonicManager: MnemonicManager
  
  // MARK: - Init
  
  init(view: MnemonicRecoveryView, mnemonicManager: MnemonicManager = MnemonicManagerImpl()) {
    self.view = view
    self.view?.displayRecoveryButton(isHidden: true)
    self.mnemonicManager = mnemonicManager
  }
  
  // MARK: - Public
  
  func add(_ suggestionWord: String, to text: String) {
    let updatedText = MnemonicHelper.addSuggestionWord(to: text, suggestionWord)
    view?.displayPickedWordFromSuggestionList(updatedText: updatedText)
    clearSuggestionList()
    highlightWrongWords(in: updatedText)
    mnemonic = updatedText
    validateMnemonic()
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
  
  func transitionToPinScreen() {
    let pinViewController = PinViewController.createFromStoryboard()    
    
    pinViewController.mode = .createPinFirstStep
    
    let mnemonicRecoveryViewController =
      view as! MnemonicRecoveryViewController
    mnemonicRecoveryViewController.navigationController?
      .pushViewController(pinViewController,
                          animated: true)
  }
  
  func highlightWrongWords(in text: String) {
    let phrases = MnemonicHelper.getSeparatedWords(from: text)
    
    var attributedString = NSMutableAttributedString(string: text)
    for word in phrases {
      if !MnemonicHelper.mnemonicWordIsExist(word) {
        attributedString = MnemonicHelper.getHighlightedAttributedString(attributedString: attributedString,
                                                                         word: word,
                                                                         in: text,
                                                                         highlightColor: Asset.Colors.red.color)
      }
    }
    
    view?.displayHighlightedWords(attributedStrings: attributedString)
  }
  
  func validateMnemonic() {
    let phrases = MnemonicHelper.getSeparatedWords(from: mnemonic)

    for word in phrases {
      if !MnemonicHelper.mnemonicWordIsExist(word) {
        view?.displayRecoveryButton(isHidden: true)
        view?.setHighlightTextView(isEnabled: true)
        return
      } else {
        view?.setHighlightTextView(isEnabled: false)
      }
    }
    
    guard phrases.count > wordsNumberInMnemonic else {
      view?.displayRecoveryButton(isHidden: true)
      return
    }
    
    view?.displayRecoveryButton(isHidden: false)
  }
}

// MARK: - MnemonicRecoveryPresenter

extension MnemonicRecoveryPresenterImpl: MnemonicRecoveryPresenter {

  func suggestionWordWasPressed(suggestionWord: String, text: String) {
    add(suggestionWord, to: text)
  }

  func textViewWasChanged(text: String) {
    clearSuggestionList()
    
    guard text.count > 0 else { return }
    
    mnemonic = text
    suggestionListRequest(by: text)
    highlightWrongWords(in: text)
    validateMnemonic()
  }

  func recoveryButtonWasPressed() {
    store(mnemonic: mnemonic)
    transitionToPinScreen()
  }
  
}

private extension MnemonicRecoveryPresenterImpl {
  private func store(mnemonic: String) {
    _ = mnemonicManager.encryptAndStoreInKeychain(mnemonic: mnemonic)
  }
}

