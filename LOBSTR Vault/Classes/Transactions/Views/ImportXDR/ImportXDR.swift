import UIKit

protocol ImportXDROutput {
  func submitXDR(_ xdr: String)
}

protocol ImportXDRInput {
  func setError(error: String)
  func closePopup()
  func setProgressAnimation(isEnable: Bool)
}

class ImportXDR: UIView, UITextViewDelegate {
  
  @IBOutlet weak var importXDRLabel: UILabel!
  @IBOutlet weak var importXDRDescriptionLabel: UILabel!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var errorLabel: UILabel!
  
  var output: ImportXDROutput?
  var popoverDelegate: CustomPopoverDelegate?
  
  let progressHUD = ProgressHUD(withBackground: true)
  
  // MARK: - IBAction
  
  @IBAction func submitButtonAction(_ sender: Any) {
    output?.submitXDR(textView.text)
  }
  
  @IBAction func closeButtonAction(_ sender: Any) {
    popoverDelegate?.closePopover()
  }
  
  // MARK: - Lifecycle
  
  override func layoutSubviews() {
    setAppearance()
    setStaticString()
    
    textView.delegate = self
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if(text == "\n") {
      textView.resignFirstResponder()
      return false
    }
    return true
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    AppearanceHelper.set(submitButton, with: L10n.buttonTitleSubmit)
    
    textView.layer.borderWidth = 1
    textView.layer.cornerRadius = 5
    layer.cornerRadius = 10
  }
  
  private func setStaticString() {
    importXDRLabel.text = L10n.textAddTransactionTitle
    importXDRDescriptionLabel.text = L10n.textAddTransactionDescription
  }
  
  private func setTextView(withError: Bool) {
    if withError {
      textView.layer.borderColor = Asset.Colors.red.color.cgColor
      errorLabel.isHidden = false
    } else {
      textView.layer.borderColor = Asset.Colors.grayOpacity30.color.cgColor
      errorLabel.isHidden = true
    }
  }
}

// MARK: - ImportXDRView

extension ImportXDR: ImportXDRInput {
  
  func setError(error: String) {
    errorLabel.text = error
    setTextView(withError: true)
  }
  
  func closePopup() {
    popoverDelegate?.closePopover()
  }
  
  func setProgressAnimation(isEnable: Bool) {
    isEnable ? progressHUD.display(onView: self) : progressHUD.remove()
  }
  
}
