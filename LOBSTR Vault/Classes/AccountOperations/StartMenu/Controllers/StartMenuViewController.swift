import UIKit

class StartMenuViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .startMenu
  
  var presenter: StartMenuPresenter!
  
  @IBOutlet weak var termsButton: UIButton!
  @IBOutlet weak var createNewAccountButton: UIButton!
  @IBOutlet weak var restoreAccountButton: UIButton!
  
  @IBOutlet weak var infoLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter = StartMenuPresenterImpl(view: self)
    presenter.startMenuViewDidLoad()
    
    setAppearance()
    setStaticStrings()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setNavigationController()
  }
  
  // MARK: - IBAction
  
  @IBAction func createNewAccountButtonAction(_ sender: Any) {
    presenter.createNewAccountButtonWasPressed()
  }
  
  @IBAction func restoreAccountButtonAction(_ sender: Any) {
    presenter.restoreAccountButtonWasPressed()
  }
  
  @IBAction func termsButtonAction(_ sender: Any) {
    presenter.termsButtonWasPressed()
  }
  
  @IBAction func helpButtonAction(_ sender: Any) {
    presenter.helpButtonWasPressed()
  }
  
  // MARK: - Public
  
  // MARK: - Private
  private func setNavigationController() {
//    navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  private func setAppearance() {
    AppearanceHelper.set(createNewAccountButton, with: L10n.buttonTitleCreateNewAccount)
    AppearanceHelper.set(restoreAccountButton, with: L10n.buttonTitleRestoreAccount)
    
    restoreAccountButton.layer.borderColor = Asset.Colors.main.color.cgColor
    restoreAccountButton.layer.borderWidth = 1
  }
  
  private func setStaticStrings() {
    infoLabel.text = L10n.textSecureYourLumens
  }
  
}

// MARK: - StartMenuView

extension StartMenuViewController: StartMenuView {
  
  func setTermsButton() {
    termsButton.setTitle(L10n.buttonTitleTerms, for: .normal)
  }
  
  func openPrivacyPolicy(by url: URL) {
    UIApplication.shared.open(url)
  }
}
