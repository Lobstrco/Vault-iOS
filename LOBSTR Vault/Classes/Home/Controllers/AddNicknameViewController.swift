//

import UIKit

enum TextFieldType {
  case publicKey
  case nickname
}

protocol AddNicknameDelegate: AnyObject {
  func nicknameWasAdded()
  func showICloudSyncAdviceAlert()
  func showNoInternetConnectionAlert()
}

class AddNicknameViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .home
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var descriptionLabel: UILabel!
  
  @IBOutlet var publicKeyTextField: UITextField!
  @IBOutlet var publicKeyPlaceholderLabel: UILabel!
  @IBOutlet var publicKeyTextViewDescriptionLabel: UILabel!
  @IBOutlet var publicKeyTextViewErrorLabel: UILabel!

  @IBOutlet var nicknameTextField: UITextField!
  @IBOutlet var nicknamePlaceholderLabel: UILabel!
  @IBOutlet var nicknameTextViewDescriptionLabel: UILabel!
  @IBOutlet var saveButton: UIButton!
  
  var presenter: AddNicknamePresenter!
  weak var delegate: AddNicknameDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setAppearance()
    setStaticString()
    
    presenter = AddNicknamePresenterImpl(view: self, delegate: delegate)
    presenter.viewDidLoad()
  }
 
  // MARK: - IBActions
  
  @IBAction func closeButtonAction(_ sender: Any) {
    presenter.closeButtonWasPressed()
  }
  
  @IBAction func saveButtonAction(_ sender: Any) {
    presenter.saveButtonWasPressed()
  }

  // MARK: - Private
  
  private func setAppearance() {
    AppearanceHelper.set(saveButton, with: L10n.buttonTextNicknameSave)
    
    publicKeyTextField.delegate = self
    publicKeyTextField.layer.borderWidth = 1
    publicKeyTextField.layer.cornerRadius = 5
    publicKeyTextField.layer.borderColor = Asset.Colors.grayOpacity15.color.cgColor
    publicKeyTextField.clearButtonMode = .always
    publicKeyTextField.contentVerticalAlignment = .center
    publicKeyTextField.setLeftPaddingPoints(10)

    nicknameTextField.delegate = self
    nicknameTextField.layer.borderWidth = 1
    nicknameTextField.layer.cornerRadius = 5
    nicknameTextField.layer.borderColor = Asset.Colors.grayOpacity15.color.cgColor
    nicknameTextField.clearButtonMode = .always
    nicknameTextField.contentVerticalAlignment = .center
    nicknameTextField.setLeftPaddingPoints(10)
  }
  
  private func setStaticString() {
    titleLabel.text = L10n.textAddNicknameTitle
    descriptionLabel.text = L10n.textAddNicknameDescription
    publicKeyPlaceholderLabel.text = L10n.textAddNicknamePublicKeyPlaceholder
    publicKeyTextViewDescriptionLabel.text = L10n.textAddNicknamePublicKeyDescription
    nicknamePlaceholderLabel.text = L10n.textAddNicknameNicknamePlaceholder
    nicknameTextViewDescriptionLabel.text = L10n.textAddNicknameNicknameDescription
  }
}

// MARK: - UITextFieldDelegate

extension AddNicknameViewController: UITextFieldDelegate {
  func textFieldDidChangeSelection(_ textField: UITextField) {
    guard let textFieldText = textField.text else { return }
    let type: TextFieldType = textField == publicKeyTextField ? .publicKey : .nickname
    presenter.textFieldDidChange(text: textFieldText, type: type)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let textFieldText = textField.text,
          let rangeOfTextToReplace = Range(range, in: textFieldText)
    else {
      return false
    }
    
    let type: TextFieldType = textField == publicKeyTextField ? .publicKey : .nickname
    let limitCount = type == .publicKey ? 56 : 20
    let substringToReplace = textFieldText[rangeOfTextToReplace]
    let count = textFieldText.count - substringToReplace.count + string.count
    return count <= limitCount
  }
}

// MARK: - AddNicknameView

extension AddNicknameViewController: AddNicknameView {
  func closeScreen(isAfterSave: Bool, isNeedToShowInternetConnectionAlert: Bool) {
    dismiss(animated: true) { [weak self] in
      guard let self = self else { return }
      guard !isNeedToShowInternetConnectionAlert else {
        self.presenter.showNoInternetConnectionAlert()
        return
      }
      
      if isAfterSave {
        self.presenter.showICloudSyncAdviceAlert()
      }
    }
  }
  
  func setSaveButton(isEnabled: Bool) {
    saveButton.isEnabled = isEnabled
    let color = isEnabled ? Asset.Colors.main.color : Asset.Colors.disabled.color
    saveButton.backgroundColor = color
  }
  
  func setPlaceholder(for type: TextFieldType, isHidden: Bool) {
    switch type {
    case .publicKey:
      publicKeyPlaceholderLabel.isHidden = isHidden
    case .nickname:
      nicknamePlaceholderLabel.isHidden = isHidden
    }
  }
  
  func setError(isHidden: Bool, error: String) {
    publicKeyTextViewErrorLabel.text = error
    let color = isHidden ? Asset.Colors.grayOpacity30.color.cgColor : Asset.Colors.red.color.cgColor
    publicKeyTextField.layer.borderColor = color
    publicKeyTextViewDescriptionLabel.isHidden = !isHidden
    publicKeyTextViewErrorLabel.isHidden = isHidden
  }
}
