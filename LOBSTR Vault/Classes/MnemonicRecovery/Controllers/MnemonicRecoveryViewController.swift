import UIKit

class MnemonicRecoveryViewController: UIViewController, MnemonicRecoveryView,
  MnemonicRecoveryStoryboardCreation {
  @IBOutlet var recoveryButton: UIButton!
  @IBOutlet var textView: UITextView!
  
  var presenter: MnemonicRecoveryPresenter!
  var mnemonicSuggestionsView: MnemonicSuggestionsView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    textView.delegate = self
    
    presenter = MnemonicRecoveryPresenterImpl(view: self)
    setupMnemonicSuggestionsView()
  }
  
  // MARK: - RecoveryView
  
  func displayRecoveryButton(isEnabled: Bool) {
    recoveryButton.isHidden = !isEnabled
  }
  
  func displaySuggestionList(suggestionList: [String]) {
    mnemonicSuggestionsView?.setData(suggestions: suggestionList)
  }
  
  func displayPickedWordFromSuggestionList(updatedText: String) {
    textView.text = updatedText
  }
  
  func displayHighlightedWords(attributedStrings: [NSMutableAttributedString]) {
    for string in attributedStrings {
      textView.attributedText = string
    }
  }
}

// MARK: - UITextViewDelegate

extension MnemonicRecoveryViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    presenter.textViewWasChanged(text: textView.text)
  }
}

// MARK: - MnemonicSuggestionsViewDelegate

extension MnemonicRecoveryViewController: MnemonicSuggestionsViewDelegate {
  func setupMnemonicSuggestionsView() {
    mnemonicSuggestionsView = Bundle.main.loadNibNamed("MnemonicSuggestionsView",
                                                       owner: self,
                                                       options: nil)?.first as? MnemonicSuggestionsView
    mnemonicSuggestionsView?.delegate = self
    textView.inputAccessoryView = mnemonicSuggestionsView
  }
  
  func suggestionWordWasPressed(_ suggestionWord: String) {
    presenter.suggestionWordWasPressed(suggestionWord: suggestionWord, text: textView.text)
  }
}
