import UIKit

protocol BackUpAccountView: class {
  
}

class BackUpAccountViewController: UIViewController, StoryboardCreation, BackUpAccountView {
  static var storyboardType: Storyboards = .backUpAccount
  
  var presenter: BackUpAccountPresenter!
  
  @IBOutlet var understandButton: UIButton!
  @IBOutlet var backupTitleLabel: UILabel!
  @IBOutlet var backupDescriptionlabel: UILabel!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter = BackUpAccountPresenterImpl(view: self,
                                           navigationController: navigationController!)
    presenter.backUpAccountViewDidLoad()
    
    setStaticStrings()
    setAppearance()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  // MARK: - IBActions
  
  @IBAction func understandButtonAction(_ sender: UIButton) {
    presenter.understandButtonWasPressed()
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    AppearanceHelper.set(navigationController)
    AppearanceHelper.set(understandButton, with: L10n.buttonTitleUnderstand)
    AppearanceHelper.setBackButton(in: navigationController)
  }
  
  private func setStaticStrings() {
    backupTitleLabel.text = L10n.textBackupTitle
    backupDescriptionlabel.text = L10n.textBackupDescription
  }
}
