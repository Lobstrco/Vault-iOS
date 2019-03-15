import UIKit
import PKHUD

class PublicKeyViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .publicKey
  
  var presenter: PublicKeyPresenter!
  
  @IBOutlet var publicKeyLabel: UILabel!
  @IBOutlet var publicKeyTitleLabel: UILabel!
  @IBOutlet var publicKeyDescriptionLabel: UILabel!
  
  @IBOutlet var nextButton: UIButton!
  @IBOutlet var copyButton: UIButton!
  
  @IBOutlet var qrCodeImageView: UIImageView!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter = PublicKeyPresenterImpl(view: self,
                                       navigationController: navigationController!)
    
    presenter.publicKeyViewDidLoad()
    setStaticStrings()
    setAppearance()
  }
  
  // MARK: - IBActions
  
  @IBAction func nextButtonAction(_ sender: Any) {
    presenter.nextButtonWasPressed()
  }
  
  @IBAction func copyKeyButtonAction(_ sender: Any) {
    presenter.copyKeyButtonWasPressed()
    HUD.flash(.labeledSuccess(title: nil, subtitle: L10n.animationCopy), delay: 1.0)
  }
  
  @IBAction func logoutButtonAction(_ sender: Any) {
    presenter.logoutButtonWasPressed()
  }
  
  @IBAction func helpButtonAction(_ sender: Any) {
    presenter.helpButtonWasPressed()
  }
  
  // MARK: - Private
  
  private func setStaticStrings() {
    publicKeyTitleLabel.text = L10n.textPublicKeyTitle
    publicKeyDescriptionLabel.text = L10n.textPublicKeyDescription
    
    nextButton.setTitle(L10n.buttonTitleNext, for: .normal)
    copyButton.setTitle(L10n.buttonTitleCopyKey, for: .normal)
  }
  
  private func setAppearance() {    
    AppearanceHelper.set(nextButton, with: L10n.buttonTitleNext)
    navigationItem.hidesBackButton = true
  }
}

// MARK: - PublicKeyView

extension PublicKeyViewController: PublicKeyView {
  
  func setPublicKey(_ publicKey: String) {
    publicKeyLabel.text = publicKey
  }
  
  func setProgressAnimation(isDisplay: Bool) {
    isDisplay ? HUD.show(.labeledProgress(title: nil, subtitle: L10n.animationWaiting)) : HUD.hide()
  }
  
  func setQRCode(from publicKey: String) {
    qrCodeImageView.image = UtilityHelper.generateQRCode(from: publicKey)
  }
  
  func setLogoutAlert() {
    let alert = UIAlertController(title: L10n.logoutAlertTitle, message: L10n.logoutAlertMessage, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleLogout, style: .destructive, handler: { _ in
      self.presenter.logoutOperationWasConfirmed()
    }))
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel))
    
    self.present(alert, animated: true, completion: nil)
  }
}
