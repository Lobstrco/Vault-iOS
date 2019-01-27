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
    
  }
  
  // MARK: - Private
  
  private func setupAppearance() {
    pinDotView.setupAppearance(with: (fillColor: Asset.Colors.white.color, outColor: Asset.Colors.red.color))
    numberPadView.setupAppearance(with: Asset.Colors.white.color)
  }
  
  private func setStaticStrings() {
    logoutButton?.setTitle(L10n.buttonTitleLogout, for: .normal)
    logOutInfoLabel?.text = L10n.textLogoutInfo
  }
  
}

// MARK: - PinView

extension PinEnterViewController: PinView {
  
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