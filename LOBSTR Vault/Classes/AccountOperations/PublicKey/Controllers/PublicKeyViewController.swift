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
  
  private func generateQRCode(from string: String) -> UIImage? {
    let data = string.data(using: String.Encoding.ascii)
    
    if let filter = CIFilter(name: "CIQRCodeGenerator") {
      filter.setValue(data, forKey: "inputMessage")
      let transform = CGAffineTransform(scaleX: 3, y: 3)
      
      if let output = filter.outputImage?.transformed(by: transform) {
        return UIImage(ciImage: output)
      }
    }
    
    return nil
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
    qrCodeImageView.image = generateQRCode(from: publicKey)
  }
}
