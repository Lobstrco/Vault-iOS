import UIKit

protocol NicknameDialogDelegate {
  func submitNickname(with text: String, by index: Int?)
}

class NicknameDialogViewController: UIViewController, StoryboardCreation {

  static var storyboardType: Storyboards = .home
  
  @IBOutlet var contentView: UIView! {
    didSet {
      contentView.layer.cornerRadius = 5
    }
  }
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var textField: UITextField!
  @IBOutlet var textViewPlaceholderLabel: UILabel!
  @IBOutlet var textViewDescriptionLabel: UILabel!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet var contentViewTopConstraint: NSLayoutConstraint!
  
  var delegate: NicknameDialogDelegate?
  var index: Int?
  var nickName: String?
  let constantHeight: CGFloat = 140
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setAppearance()
    setStaticString()
  }
  
  // MARK: - IBActions
  
  @IBAction func cancelButtonAction(_ sender: Any) {
    dismiss(animated: false, completion: nil)
  }

  @IBAction func saveButtonAction(_ sender: Any) {
    let nickname: String = textField.text ?? ""
    let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
    delegate?.submitNickname(with: trimmedNickname, by: index)
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func textFieldDidChange(_ sender: Any) {
    if let text = textField.text, !text.isEmpty {
      textViewPlaceholderLabel.isHidden = true
    } else {
      textViewPlaceholderLabel.isHidden = false
    }
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    self.view.hideKeyboardWhenTapped()
    AppearanceHelper.set(saveButton, with: L10n.buttonTextNicknameSave)
    
    if let nickName = self.nickName, !nickName.isEmpty {
      titleLabel.text = L10n.textChangeNicknameTitle
      textViewPlaceholderLabel.isHidden = true
      textField.text = nickName
    } else {
      titleLabel.text = L10n.textSetNicknameTitle
      textViewPlaceholderLabel.isHidden = false
    }
    textField.layer.borderWidth = 1
    textField.layer.cornerRadius = 5
    textField.layer.borderColor = Asset.Colors.grayOpacity15.color.cgColor
    textField.contentVerticalAlignment = .center
    textField.clearButtonMode = .always
    textField.delegate = self
    textField.setLeftPaddingPoints(10)
  }
  
  private func setStaticString() {
    descriptionLabel.text = L10n.textNicknameDescription
    textViewPlaceholderLabel.text = L10n.textNicknameTextViewPlaceholder
    textViewDescriptionLabel.text = L10n.textNicknameTextViewDescrition
  }
}

extension NicknameDialogViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    let nickname: String = textField.text ?? ""
    delegate?.submitNickname(with: nickname, by: index)
    dismiss(animated: false, completion: nil)
    textField.resignFirstResponder()
    return true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let textFieldText = textField.text,
          let rangeOfTextToReplace = Range(range, in: textFieldText)
    else {
      return false
    }
    let substringToReplace = textFieldText[rangeOfTextToReplace]
    let count = textFieldText.count - substringToReplace.count + string.count
    return count <= 30
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    contentViewTopConstraint.constant -= constantHeight
  }
  
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
    contentViewTopConstraint.constant += constantHeight
  }
}
