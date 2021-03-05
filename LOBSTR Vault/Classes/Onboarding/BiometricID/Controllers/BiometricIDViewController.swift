import UIKit
import PKHUD

class BiometricIDViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .biometricID

  var presenter: BiometricIDPresenter!
  
  @IBOutlet var protectTitleLabel: UILabel!
  @IBOutlet var protectTitleDescriptionLabel: UILabel!
  @IBOutlet var turnOnDecriptionLabel: UILabel!
  
  @IBOutlet var turnOnButton: UIButton!
  @IBOutlet var skipButton: UIButton!

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    presenter = BiometricIDPresenterImpl(view: self,
                                         navigationController: navigationController!)

    presenter.biometricIDViewDidLoad()
    
    setStaticStrings()
  }
}

// MARK: - IBActions

extension BiometricIDViewController {
  @IBAction func turnOnButtonAction(_ sender: UIButton) {
    presenter.turnOnButtonWasPressed()
  }

  @IBAction func skipButtonAction(_ sender: UIButton) {
    presenter.skipButtonWasPressed()
  }
  
  func setStaticStrings() {
    protectTitleLabel?.text = L10n.textProtectYourWallet
    protectTitleDescriptionLabel?.text = L10n.textProtectYourWalletDescription
    turnOnDecriptionLabel?.text = L10n.textTurnOnDescription
  }
}

// MARK: - BiometricIDView

extension BiometricIDViewController: BiometricIDView {

  func setErrorAlert(for error: Error) {
    UIAlertController.defaultAlert(for: error, presentingViewController: self)
  }
  
  func setBiometricButton(with type: BiometricType) {
    switch type {
    case .face:
      AppearanceHelper.set(turnOnButton, with: L10n.buttonTitleTurnOnFaceid)
      case .touch:
      AppearanceHelper.set(turnOnButton, with: L10n.buttonTitleTurnOnFingerprint)
    case .none:
      AppearanceHelper.set(turnOnButton, with: L10n.buttonTitleTurnOn)
    }
  }
  
  func setProgressAnimation(isDisplay: Bool) {
    DispatchQueue.main.async {
      isDisplay ? HUD.show(.labeledProgress(title: nil, subtitle: L10n.animationWaiting)) : HUD.hide()
    }
  }
}
