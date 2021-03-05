import UIKit

class StartMenuViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .startMenu
  
  var presenter: StartMenuPresenter!
  
//  @IBOutlet weak var termsButton: UIButton!
  @IBOutlet weak var createNewAccountButton: UIButton!
  @IBOutlet weak var restoreAccountButton: UIButton!
  @IBOutlet weak var signInWithCardButton: UIButton!
  
  @IBOutlet weak var infoLabel: UILabel!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addObservers()
    presenter = StartMenuPresenterImpl(view: self)
    presenter.startMenuViewDidLoad()
    
    setAppearance()
    setStaticStrings()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: animated)
    navigationController?.setStatusBar(backgroundColor: Asset.Colors.white.color)
    navigationController?.navigationBar.barTintColor = Asset.Colors.white.color
    navigationController?.navigationBar.backgroundColor = Asset.Colors.white.color
    navigationController?.navigationBar.shadowImage = UIImage()
    navigationController?.navigationBar.tintColor = Asset.Colors.main.color
    navigationController?.navigationBar.isTranslucent = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }
  
  // MARK: - IBAction
  
  @IBAction func createNewAccountButtonAction(_ sender: Any) {
    presenter.createNewAccountButtonWasPressed()
  }
  
  @IBAction func restoreAccountButtonAction(_ sender: Any) {
    presenter.restoreAccountButtonWasPressed()
  }
  
  @IBAction func signInWithCardButtonAction(_ sender: Any) {
    presenter.signInWithCardButtonWasPressed()
  }
  
  @IBAction func termsButtonAction(_ sender: Any) {
    presenter.termsButtonWasPressed()
  }
  
  @IBAction func privacyButtonAction(_ sender: Any) {
    presenter.privacyButtonWasPressed()
  }
  
  @IBAction func helpButtonAction(_ sender: Any) {
    presenter.helpButtonWasPressed()
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    AppearanceHelper.set(createNewAccountButton, with: L10n.buttonTitleCreateNewAccount)
    AppearanceHelper.set(restoreAccountButton, with: L10n.buttonTitleRestoreAccount)
    AppearanceHelper.set(signInWithCardButton, with: "Use Signer Card")
    
    restoreAccountButton.layer.borderColor = Asset.Colors.main.color.cgColor
    restoreAccountButton.layer.borderWidth = 1
    
    signInWithCardButton.layer.borderColor = Asset.Colors.main.color.cgColor
    signInWithCardButton.layer.borderWidth = 1
  }
  
  private func setStaticStrings() {
    infoLabel.text = L10n.textSecureYourLumens
  }
  
}

// MARK: - StartMenuView

extension StartMenuViewController: StartMenuView {
  
  func setTermsButton() {
//    termsButton.setTitle(L10n.buttonTitleTerms, for: .normal)
  }
  
  func open(by url: URL) {
    UIApplication.shared.open(url)
  }
}

extension StartMenuViewController {
  func addObservers() {
    NotificationCenter.default.addObserver(self,
                                          selector: #selector(checkAppVersion),
                                          name: UIApplication.didBecomeActiveNotification,
                                          object: nil)
  }
 
  @objc func checkAppVersion() {
    presenter.checkAppVersion()
  }
  
}
