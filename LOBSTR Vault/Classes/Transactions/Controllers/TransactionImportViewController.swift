import stellarsdk
import UIKit

protocol TransactionImportDelegate {
  func submitTransaction(with xdr: String)
}

class TransactionImportViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .transactions
  
  @IBOutlet var mainLabel: UILabel!
  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var textView: UITextView!
  @IBOutlet var submitButton: UIButton!
  @IBOutlet var errorLabel: UILabel!
  @IBOutlet var clipboardView: UIView!
  @IBOutlet var pasteFromClipboardButton: UIButton!
  @IBOutlet var placeholderLabel: UILabel!
  
  var presenter: TransactionImportPresenter!
  
  var delegate: TransactionImportDelegate?
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setAppearance()
    setStaticString()
    
    textView.delegate = self
    
    presenter = TransactionImportPresenterImpl(view: self, delegate: delegate)
    presenter.viewDidLoad()
  }

  // MARK: - IBActions
  
  @IBAction func closeButtonAction(_ sender: Any) {
    presenter.closeButtonWasPressed()
  }
  
  @IBAction func submitButtonAction(_ sender: Any) {
    presenter.submitButtonWasPressed(with: textView.text)
  }
  
  @IBAction func pasteFromClipboardButtonAction(_ sender: Any) {
    presenter.pasteFromClipboardButtonWasPressed()
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    AppearanceHelper.set(submitButton, with: L10n.buttonTitleNext)
    
    textView.layer.borderWidth = 1
    textView.layer.cornerRadius = 5
    textView.layer.borderColor = Asset.Colors.grayOpacity30.color.cgColor
    textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
  }
  
  private func setStaticString() {
    mainLabel.text = L10n.textAddTransactionTitle
    descriptionLabel.text = L10n.textAddTransactionDescription
    pasteFromClipboardButton.setTitle(L10n.buttonTitlePasteFromClipboard, for: .normal)
    placeholderLabel.text = L10n.textAddTransactionPlaceholder
  }
}

extension TransactionImportViewController: UITextViewDelegate {
  func textView(_ textView: UITextView,
                shouldChangeTextIn range: NSRange,
                replacementText text: String) -> Bool
  {
    if text == "\n" {
      textView.resignFirstResponder()
      return false
    }
    return true
  }
  
  func textViewDidChange(_ textView: UITextView) {
    presenter.textViewDidChange(text: textView.text)
  }
}

extension TransactionImportViewController: TransactionImportView {
  func closeScreen() {
    dismiss(animated: true, completion: nil)
  }
  
  func setError(isHidden: Bool, error: String) {
    errorLabel.text = error
    let color = isHidden ? Asset.Colors.grayOpacity30.color.cgColor : Asset.Colors.red.color.cgColor
    textView.layer.borderColor = color
    errorLabel.isHidden = isHidden
  }
  
  func setClipboard(text: String) {
    clipboardView.isHidden = text.isEmpty
  }
  
  func textWasPasted(text: String) {
    textView.text = text
    clipboardView.isHidden = true
  }
  
  func setSubmitButton(isEnabled: Bool) {
    submitButton.isEnabled = isEnabled
    let color = isEnabled ? Asset.Colors.main.color : Asset.Colors.disabled.color
    submitButton.backgroundColor = color
  }
  
  func setPlaceholder(isHidden: Bool) {
    placeholderLabel.isHidden = isHidden
  }
}
