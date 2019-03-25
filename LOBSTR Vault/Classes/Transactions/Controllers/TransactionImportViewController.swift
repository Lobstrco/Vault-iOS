import UIKit
import stellarsdk

protocol TransactionImportDelegate {
  func submitTransaction(with xdr: String)
}

class TransactionImportViewController: UIViewController, StoryboardCreation {

  static var storyboardType: Storyboards = .transactions
  
  @IBOutlet weak var mainLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet weak var errorLabel: UILabel!
  
  var delegate: TransactionImportDelegate?
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setAppearance()
    setStaticString()
    
    textView.delegate = self
  }

  // MARK: - IBActions
  
  @IBAction func closeButtonAction(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func submitButtonAction(_ sender: Any) {
    let xdr: String = textView.text
    guard let _ = try? TransactionEnvelopeXDR(xdr: xdr) else {
      setError("Invalid XDR")
      return
    }
    
    dismiss(animated: true, completion: nil)
    delegate?.submitTransaction(with: xdr)
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    AppearanceHelper.set(submitButton, with: L10n.buttonTitleNext)
    
    textView.layer.borderWidth = 1
    textView.layer.cornerRadius = 5
    textView.layer.borderColor = Asset.Colors.grayOpacity30.color.cgColor
  }
  
  private func setStaticString() {
    mainLabel.text = L10n.textAddTransactionTitle
    descriptionLabel.text = L10n.textAddTransactionDescription
  }
  
  private func setError(_ error: String) {
    errorLabel.text = error
    textView.layer.borderColor = Asset.Colors.red.color.cgColor
    errorLabel.isHidden = false
  }
}

extension TransactionImportViewController: UITextViewDelegate {
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if(text == "\n") {
      textView.resignFirstResponder()
      return false
    }
    return true
  }
}
