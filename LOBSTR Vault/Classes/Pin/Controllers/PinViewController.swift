import UIKit

protocol PinView: AnyObject {
  func setTitle(_ title: String)
  func setCancelBarButtonItem()
  func fillPinDot(at index: Int)
  func clearPinDot(at index: Int)
  func clearPinDots()
  func shakePinView()
  func setNavigationItem()
  func hideBackButton()
  func show(error: String)
  func executeCompletion()
  func setSimplePinAlert()
  func setKeyboardRigthButton(isEnabled: Bool)
  func transitionToHomeScreen()
}

class PinViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .pin
  
  var mode: PinMode = .undefined
  
  @IBOutlet var numberPadView: NumberPadView!
  @IBOutlet var pinDotView: PinDotView!
  @IBOutlet var errorLabel: UILabel!
  
  let impact = UIImpactFeedbackGenerator(style: .light)
  var presenter: PinPresenter!
  
  var completion: (() -> Void)?
  
  lazy var cancelBarButtonItem: UIBarButtonItem = {
    let selector = #selector(canceBarButtonItemAction)
    let item = UIBarButtonItem(barButtonSystemItem: .cancel,
                               target: self, action: selector)
    return item
  }()
  
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter = PinPresenterImpl(view: self, mode: mode)
    
    numberPadView.delegate = self
    
    presenter.pinViewDidLoad()
    pinDotView.clearPinDots()
    
    setAppearance()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    presenter.pinViewWillAppear()
    switch mode {
    case .changePin, .enterPinForMnemonicPhrase, .createNewPinFirstStep, .createNewPinSecondStep:
      navigationController?.setNavigationBarAppearance(backgroundColor: Asset.Colors.background.color)
    default: break
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    switch mode {
    case .changePin, .enterPinForMnemonicPhrase, .createNewPinFirstStep, .createNewPinSecondStep:
      navigationController?.setNavigationBarAppearanceWithoutSeparatorForStandardAppearance()
    default: break
    }
  }

  @IBAction func helpButtonAction(_ sender: Any) {    
    presenter.helpButtonWasPressed()
  }
  
  @objc func canceBarButtonItemAction() {
    dismiss(animated: true, completion: nil)
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    pinDotView.setupAppearance(with: (fillColor: Asset.Colors.main.color, outColor: Asset.Colors.background.color))
    numberPadView.setupAppearance(with: Asset.Colors.black.color)
  }
  
  func setSimplePinAlert() {
    let alert = UIAlertController(title: L10n.textPasscodeSimpleTitle,
                                  message: L10n.textPasscodeSimpleMessage,
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.textPasscodeSimpleIgnoreButton, style: .destructive, handler: { _ in
      self.presenter.ignoreSimplePin()
    }))
    
    alert.addAction(UIAlertAction(title: L10n.textPasscodeSimpleChangeButton, style: .default, handler: { _ in
      self.presenter.changeSimplePin()
    }))
    
    present(alert, animated: true, completion: nil)
  }
}

// MARK: - PinView

extension PinViewController: PinView {
  func transitionToHomeScreen() {}
  
  func setKeyboardRigthButton(isEnabled: Bool) {
    numberPadView.rightButtonEnable(isEnabled)
  }
  
  func setTitle(_ title: String) {
    navigationItem.title = title
  }
  
  func setCancelBarButtonItem() {
    navigationController?.navigationBar.tintColor = Asset.Colors.main.color
    navigationItem.leftBarButtonItem = cancelBarButtonItem
  }
  
  func fillPinDot(at index: Int) {
    pinDotView.fillPinDot(at: index)
  }
  
  func clearPinDot(at index: Int) {
    pinDotView.clearPinDot(at: index)
  }
  
  func clearPinDots() {
    pinDotView.clearPinDots()
  }
  
  func shakePinView() {
    pinDotView.shake()
  }
  
  func setNavigationItem() {
    navigationItem.largeTitleDisplayMode = .never
  }
  
  func hideBackButton() {
    navigationItem.hidesBackButton = true
  }
  
  func show(error: String) {
    errorLabel.text = error
  }
  
  func executeCompletion() {
    completion?()
  }
}

// MARK: - NumberPadViewDelegate

extension PinViewController: NumberPadViewDelegate {
  
  func numberPadButtonWasPressed(button: NumberPadButton) {
    
    impact.impactOccurred()
    
    switch button {
    case .number(let digit):
      presenter.digitButtonWasPressed(with: digit)
    case .right:
      presenter.removeButtonWasPressed()
    default:
      break
    }
  }
}
