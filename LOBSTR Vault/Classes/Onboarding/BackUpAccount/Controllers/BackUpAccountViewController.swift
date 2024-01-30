import UIKit

protocol BackUpAccountView: AnyObject {}

class BackUpAccountViewController: UIViewController, StoryboardCreation, BackUpAccountView {
  static var storyboardType: Storyboards = .backUpAccount
  
  var presenter: BackUpAccountPresenter!
  
  @IBOutlet var understandButton: UIButton!
  @IBOutlet var backupTitleLabel: UILabel!
  @IBOutlet var backupDescriptionlabel: UILabel!
  @IBOutlet var backupAttentionlabel: UILabel!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setAppearance()
    
    presenter = BackUpAccountPresenterImpl(view: self,
                                           navigationController: navigationController!)
    presenter.backUpAccountViewDidLoad()
    
    setStaticStrings()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  // MARK: - IBActions
  
  @IBAction func understandButtonAction(_ sender: UIButton) {
    presenter.understandButtonWasPressed()
  }
  
  @IBAction func helpButtonAction(_ sender: Any) {
    presenter.helpButtonWasPressed()
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    AppearanceHelper.set(understandButton, with: L10n.buttonTitleUnderstand)
  }
  
  private func setStaticStrings() {
    backupTitleLabel.text = L10n.textBackupTitle
    backupDescriptionlabel.text = L10n.textBackupDescription
    backupAttentionlabel.text = L10n.textBackupAttention
  }
}
