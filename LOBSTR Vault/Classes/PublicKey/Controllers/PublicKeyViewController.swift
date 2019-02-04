import UIKit

protocol PublicKeyView: class {
  func setPublicKey(_ publicKey: String)
}

class PublicKeyViewController: UIViewController, StoryboardCreation, PublicKeyView {
  static var storyboardType: Storyboards = .publicKey
  
  var presenter: PublicKeyPresenter!
  
  @IBOutlet var publicKeyLabel: UILabel!
  @IBOutlet var publicKeyTitleLabel: UILabel!
  @IBOutlet var publicKeyDescriptionLabel: UILabel!
  
  @IBOutlet var nextButton: UIButton!
  @IBOutlet var copyButton: UIButton!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter = PublicKeyPresenterImpl(view: self,
                                       navigationController: navigationController!)
    
    presenter.publicKeyViewDidLoad()
    setStaticStrings()
    setAppearance()
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
  }
  
  // MARK: - PublicKeyView
  
  func setPublicKey(_ publicKey: String) {
    publicKeyLabel.text = publicKey
  }
  
  // MARK: - IBActions
  
  @IBAction func nextButtonAction(_ sender: Any) {
    presenter.nextButtonWasPressed()
  }
  
}
