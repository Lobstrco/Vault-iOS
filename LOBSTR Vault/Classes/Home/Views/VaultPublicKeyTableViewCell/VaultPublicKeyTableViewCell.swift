//

import UIKit

protocol VaultPublicKeyTableViewCellDelegate: class {
  func copyButtonDidPress()
}

class VaultPublicKeyTableViewCell: UITableViewCell {
  @IBOutlet var publicKeyLabel: UILabel!
  @IBOutlet var titleOfPublicKeyLabel: UILabel!
  @IBOutlet var copyKeyButton: UIButton!
  
  @IBOutlet var idenctionView: IdenticonView!
  
  @IBOutlet var shadowView: UIView!
  @IBOutlet var infoContainerView: UIView!
  
  weak var delegate: VaultPublicKeyTableViewCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    titleOfPublicKeyLabel.text = L10n.textVaultPublicKey
    
    AppearanceHelper.set(copyKeyButton, with: L10n.buttonTitleCopyKey)
    
    infoContainerView.layer.borderWidth = 1
    infoContainerView.layer.cornerRadius = 5
    infoContainerView.layer.borderColor = UIColor.clear.cgColor
    infoContainerView.layer.masksToBounds = true
    
    shadowView.layer.shadowOpacity = 0.2
    shadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
    shadowView.layer.shadowRadius = 4
    shadowView.layer.shadowColor = UIColor.black.cgColor
    shadowView.layer.masksToBounds = false
  }
  
  @IBAction func copyKeyButtonAction(_ sender: UIButton) {
    delegate?.copyButtonDidPress()
  }
}
