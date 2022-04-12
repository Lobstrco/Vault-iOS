import UIKit
import PKHUD

class PublicKeyPopover: UIView {

  @IBOutlet weak var copyButton: UIButton!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var publicKeyLabel: UILabel!
  @IBOutlet weak var publicKeyTitleLabel: UILabel!
  @IBOutlet weak var qrCodeImageView: UIImageView!
  
  var popoverDelegate: CustomPopoverDelegate?
  
  var publicKey: String?
  
  // MARK: - IBAction
  
  @IBAction func copyButtonAction(_ sender: Any) {
    HUD.flash(.labeledSuccess(title: nil, subtitle: L10n.animationCopy), delay: 1.0)
    UIPasteboard.general.string = publicKey
    closePopover()
  }
  
  @IBAction func closeButtonAction(_ sender: Any) {
    closePopover()
  }
  
  func initData() {
    setAppearance()
    setPublicKey()
    setQRCode()
  }
  
  // MARK: - Private
  
  private func setPublicKey() {
    self.publicKey = UserDefaultsHelper.activePublicKey
    let nickname = AccountsStorageHelper.getActiveAccountNickname()
    let publicKeyTitle = nickname.isEmpty ? L10n.textSettingsPublicKeyTitle : nickname
    publicKeyTitleLabel.text = publicKeyTitle
    self.publicKeyLabel.text = publicKey?.getTruncatedPublicKey()
  }
  
  private func setAppearance() {
    AppearanceHelper.set(copyButton, with: L10n.buttonTitleCopyKey)
    layer.cornerRadius = 10
  }
    
  private func closePopover() {
    popoverDelegate?.closePopover()
    popoverDelegate = nil
  }
  
  private func setQRCode() {
    if let key = publicKey {
      qrCodeImageView.image = UtilityHelper.generateQRCode(from: key)      
    }
  }
}
