import UIKit

enum NicknameDialogType {
  case primaryAccount
  case protectedAccount
  case otherAccount
}

protocol NicknameDialogDelegate: AnyObject {
  func submitNickname(with text: String,
                      for publicKey: String?,
                      nicknameDialogType: NicknameDialogType?)
  
  func displayNoInternetConnectionAlert()
}

class NicknameDialogViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .home

  @IBOutlet var contentView: UIView! {
    didSet {
      contentView.layer.cornerRadius = 5
    }
  }

  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var textField: UITextField!
  @IBOutlet var textViewPlaceholderLabel: UILabel!
  @IBOutlet var textViewDescriptionLabel: UILabel!
  @IBOutlet var saveButton: UIButton! {
    didSet {
      saveButton.isEnabled = false
    }
  }

  @IBOutlet var contentViewTopConstraint: NSLayoutConstraint!

  weak var delegate: NicknameDialogDelegate?
  var nickname: String?
  var trimmedNickname: String = ""
  let constantHeight: CGFloat = 140
  var type: NicknameDialogType?
  var publicKey: String?

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setAppearance()
    setStaticString()
  }

  // MARK: - IBActions

  @IBAction func cancelButtonAction(_: Any) {
    dismiss(animated: false, completion: nil)
  }

  @IBAction func saveButtonAction(_: Any) {
    let nickname: String = textField.text ?? ""
    trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)

    dismiss(animated: true) { [weak self] in
      guard let self = self else { return }
      
      if UserDefaultsHelper.isICloudSynchronizationEnabled {
        guard UIDevice.isConnectedToNetwork else {
          self.delegate?.displayNoInternetConnectionAlert()
          return
        }
        self.delegate?.submitNickname(with: self.trimmedNickname, for: self.publicKey, nicknameDialogType: self.type)
      } else {
        self.delegate?.submitNickname(with: self.trimmedNickname, for: self.publicKey, nicknameDialogType: self.type)
      }
    }
  }

  @IBAction func textFieldDidChange(_: Any) {
    updatePlaceholder()
    updateSaveButton()
  }

  // MARK: - Private

  private func updateSaveButton() {
    if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
       !text.isEmpty
    {
      saveButton.isEnabled = true
    } else {
      saveButton.isEnabled = false
    }
  }

  private func updatePlaceholder() {
    if let text = textField.text, !text.isEmpty {
      textViewPlaceholderLabel.isHidden = true
    } else {
      textViewPlaceholderLabel.isHidden = false
    }
  }

  private func setAppearance() {
    view.hideKeyboardWhenTapped()
    AppearanceHelper.set(saveButton, with: L10n.buttonTextNicknameSave)

    if let nickname = self.nickname, !nickname.isEmpty {
      titleLabel.text = L10n.textChangeNicknameTitle
      textViewPlaceholderLabel.isHidden = true
      textField.text = nickname
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
    let nickname: String = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

    guard !nickname.isEmpty else { return false }
    
    dismiss(animated: true) { [weak self] in
      guard let self = self else { return }
      
      if UserDefaultsHelper.isICloudSynchronizationEnabled {
        if UIDevice.isConnectedToNetwork {
          self.delegate?.submitNickname(with: nickname, for: self.publicKey, nicknameDialogType: self.type)
        } else {
          self.delegate?.displayNoInternetConnectionAlert()
        }
      } else {
        self.delegate?.submitNickname(with: nickname, for: self.publicKey, nicknameDialogType: self.type)
      }
    }
    
    textField.resignFirstResponder()
    return true
  }

  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool
  {
    guard let textFieldText = textField.text,
          let rangeOfTextToReplace = Range(range, in: textFieldText)
    else {
      return false
    }
    let substringToReplace = textFieldText[rangeOfTextToReplace]
    let count = textFieldText.count - substringToReplace.count + string.count
    return count <= 20
  }

  func textFieldDidBeginEditing(_: UITextField) {
    contentViewTopConstraint.constant -= constantHeight
  }

  func textFieldDidEndEditing(_: UITextField,
                              reason _: UITextField.DidEndEditingReason)
  {
    contentViewTopConstraint.constant += constantHeight
  }
}
