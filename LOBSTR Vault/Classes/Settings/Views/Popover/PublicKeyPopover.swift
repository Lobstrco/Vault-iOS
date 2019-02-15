import UIKit
import PKHUD

class PublicKeyPopover: UIView {

  @IBOutlet weak var copyButton: UIButton!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var publicKeyLabel: UILabel!
  @IBOutlet weak var publicKeyTitleLabel: UILabel!
  
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
    setStaticString()
    setPublicKey()
  }
  
  // MARK: - Private
  
  private func setPublicKey() {
    let vaultStorage = VaultStorage()
    guard let publicKeyFromKeychain = vaultStorage.getPublicKeyFromKeychain() else { return }
    self.publicKeyLabel.text = publicKeyFromKeychain
    self.publicKey = publicKeyFromKeychain
  }
  
  private func setAppearance() {
    AppearanceHelper.set(copyButton, with: L10n.buttonTitleCopyKey)
    layer.cornerRadius = 10
  }
  
  private func setStaticString() {
    publicKeyTitleLabel.text = L10n.textSettingsPublicKeyTitle
  }
  
  private func closePopover() {
    popoverDelegate?.closePopover()
    popoverDelegate = nil
  }
}
