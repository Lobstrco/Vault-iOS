import UIKit

class PinEnterViewController: UIViewController, StoryboardCreation {

  static var storyboardType: Storyboards = .pin
  
  var mode: PinMode = .enterPin
  
  @IBOutlet var numberPadView: NumberPadView!
  @IBOutlet var pinDotView: PinDotView!
  
  @IBOutlet var logoutButton: UIButton?
  @IBOutlet var logOutInfoLabel: UILabel?
  
  let impact = UIImpactFeedbackGenerator(style: .light)
  var presenter: PinPresenter!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter = PinPresenterImpl(view: self, mode: mode)
    
    numberPadView.delegate = self
    
    presenter.pinViewDidLoad()
    pinDotView.clearPinDots()
    setStaticStrings()
    setupAppearance()
  }
  
  // MARK: - IBAction
  
  @IBAction func logOutAction(_ sender: Any) {
    setLogoutAlert()
  }
  
  // MARK: - Private
  
  private func setupAppearance() {
    pinDotView.setupAppearance(with: (fillColor: Asset.Colors.white.color,
                                      outColor: Asset.Colors.pinDotOut.color))
    numberPadView.setupAppearance(with: Asset.Colors.white.color)
  }
  
  private func setStaticStrings() {
    logoutButton?.setTitle(L10n.buttonTitleLogout, for: .normal)
    logOutInfoLabel?.text = L10n.textLogoutInfo
  }
  
  private func setLogoutAlert() {
    let alert = UIAlertController(title: L10n.logoutAlertTitle,
                                  message: L10n.logoutAlertMessage, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleLogout,
                                  style: .destructive, handler: { _ in
      ApplicationCoordinatorHelper.logout()
    }))
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel))
    
    self.present(alert, animated: true, completion: nil)
  }  
}

// MARK: - PinView

extension PinEnterViewController: PinView {
  func setCancelBarButtonItem() {
  }
  
  func executeCompletion() {
  }
  
  func show(error: String) {
  }  
  
  func hideBackButton() {
  }  
  
  func clearPinDots() {
    pinDotView.clearPinDots()
  }
  
  func setNavigationItem() {
    
  }  
  
  func setTitle(_ title: String) {}
  
  func fillPinDot(at index: Int) {
    pinDotView.fillPinDot(at: index)
  }
  
  func clearPinDot(at index: Int) {
    pinDotView.clearPinDot(at: index)
  }
  
  func shakePinView() {
    pinDotView.shake()
  }
  
}

// MARK: - NumberPadViewDelegate

extension PinEnterViewController: NumberPadViewDelegate {
  
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
