import UIKit

protocol BiometricIDView: class {  
  func setErrorAlert(for error: Error)
}

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
    setupAppearance()
  }
  
  // MARK: - Private
  
  private func setupAppearance() {
    AppearanceHelper.set(turnOnButton, with: L10n.buttonTitleTurnOn)    
  }
  
  private func setStaticStrings() {
    turnOnButton?.setTitle(L10n.buttonTitleTurnOn, for: .normal)
    
    protectTitleLabel?.text = L10n.textProtectYourWallet
    protectTitleDescriptionLabel?.text = L10n.textProtectYourWalletDescription
    turnOnDecriptionLabel?.text = L10n.textTurnOnDescription
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
}

// MARK: - BiometricIDView

extension BiometricIDViewController: BiometricIDView {

  func setErrorAlert(for error: Error) {
    UIAlertController.defaultAlert(for: error, presentingViewController: self)
  }
}
