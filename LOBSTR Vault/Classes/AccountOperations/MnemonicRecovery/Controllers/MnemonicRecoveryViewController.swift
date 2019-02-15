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
  
  override func viewDidLayoutSubviews() {
    AppearanceHelper.setDashBorders(for: textView, with: Asset.Colors.gray.color.cgColor)
  }
  
  // MARK: - IBActions
  
  @IBAction func recoveryButtonAction(_ sender: Any) {
    presenter.recoveryButtonWasPressed()
  }
  
  @IBAction func helpButtonAction(_ sender: Any) {
    presenter.helpButtonWasPressed()
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    AppearanceHelper.set(nextButton, with: L10n.buttonTitleNext)    
    textView.textContainerInset = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 20)
  }
  
  private func setStaticStrings() {
    restoreAccountInfoLabel.text = L10n.textRestoreInfo
    navigationItem.title = L10n.navTitleRestoreAccount
//    textView.placeholder = L10n.textRestorePlaceholder
  }
}

// MARK: - RecoveryView

extension MnemonicRecoveryViewController: MnemonicRecoveryView {
  
  func displayRecoveryButton(isHidden: Bool) {
    nextButton.isHidden = isHidden
  }
  
  func displaySuggestionList(suggestionList: [String]) {
    mnemonicSuggestionsView?.setData(suggestions: suggestionList)
  }
  
  func displayPickedWordFromSuggestionList(updatedText: String) {
    textView.text = updatedText
  }
  
  func displayHighlightedWords(attributedStrings: NSMutableAttributedString) {
    
    attributedStrings.addAttribute(NSAttributedString.Key.font,
                                  value: UIFont.systemFont(ofSize: 16),
                                  range: NSRange(location: 0, length: textView.text.utf16.count))
    
    textView.attributedText = attributedStrings
  }
  
  func setHighlightTextView(isEnabled: Bool) {
    let borderColor = isEnabled ? Asset.Colors.red.color.cgColor : Asset.Colors.gray.color.cgColor
    AppearanceHelper.changeDashBorderColor(for: textView, with: borderColor)
  }
}

// MARK: - UITextViewDelegate

extension MnemonicRecoveryViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    presenter.textViewWasChanged(text: textView.text)
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if(text == "\n") {
      textView.resignFirstResponder()
      return false
    }
    return true
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
