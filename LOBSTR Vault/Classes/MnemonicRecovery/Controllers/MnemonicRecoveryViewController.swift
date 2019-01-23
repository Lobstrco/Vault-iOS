import UIKit

class MnemonicRecoveryViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .mnemonicRecovery
  
  @IBOutlet var nextButton: UIButton!
  @IBOutlet var textView: UITextView!
  @IBOutlet var restoreAccountInfoLabel: UILabel!
  
  var presenter: MnemonicRecoveryPresenter!
  var mnemonicSuggestionsView: MnemonicSuggestionsView?
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    textView.delegate = self
    
    presenter = MnemonicRecoveryPresenterImpl(view: self)
    setupMnemonicSuggestionsView()
    
    setAppearance()
    setStaticStrings()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  // MARK: - IBActions
  
  @IBAction func recoveryButtonAction(_ sender: Any) {
    presenter.recoveryButtonWasPressed()
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    textView.layer.borderWidth = 1
    textView.layer.borderColor = Asset.Colors.gray.color.cgColor
    
    AppearanceHelper.set(nextButton, with: L10n.buttonTitleNext)
    AppearanceHelper.set(navigationController)
    AppearanceHelper.setBackButton(in: navigationController)
  }
  
  private func setStaticStrings() {
    restoreAccountInfoLabel.text = L10n.textRestoreInfo
    navigationItem.title = L10n.navTitleRestoreAccount
  }
}

// MARK: - RecoveryView

extension MnemonicRecoveryViewController: MnemonicRecoveryView {
  
  func displayRecoveryButton(isEnabled: Bool) {
    nextButton.isHidden = !isEnabled
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
    
    mnemonicSuggestionsView?.layer.shadowColor = UIColor.black.cgColor
    mnemonicSuggestionsView?.layer.shadowOffset = CGSize(width: 0, height: -1.0)
    mnemonicSuggestionsView?.layer.shadowOpacity = 0.2
    mnemonicSuggestionsView?.layer.shadowRadius = 4.0
    
    textView.inputAccessoryView = mnemonicSuggestionsView
  }
  
  func suggestionWordWasPressed(_ suggestionWord: String) {
    presenter.suggestionWordWasPressed(suggestionWord: suggestionWord, text: textView.text)
  }
}
