import UIKit

protocol UsingDifferentServiceTableViewCellDelegate: class {
  func copyKeyButtonDidPress()
  func showQRCodeButtonDidPress()
}

class UsingDifferentServiceTableViewCell: UITableViewCell {
  
  @IBOutlet var shadowView: UIView!
  @IBOutlet var infoContainerView: UIView!
  @IBOutlet var publicKeyLabel: UILabel!
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var copyKeyButton: UIButton!
  @IBOutlet var showQRButton: UIButton!
  
  weak var delegate: UsingDifferentServiceTableViewCellDelegate?
  
  // MARK: - Lifecycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    setAppearance()
    setStaticStrings()
  }
  
  // MARK: - IBActions
  
  @IBAction func copyKeyButtonAction(_ sender: UIButton) {
    delegate?.copyKeyButtonDidPress()
  }
  
  @IBAction func showQRCodeButtonAction(_ sender: UIButton) {
    delegate?.showQRCodeButtonDidPress()
  }
}

// MARK: - Private

private extension UsingDifferentServiceTableViewCell {
  
  func setAppearance() {
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
  
  func setStaticStrings() {
    titleLabel.text = "Use Vault with a different service or LOBSTR on another device"
    descriptionLabel.text = "Copy the public key or scan the QR code to add Vault signer and enable multisig on another device."
    copyKeyButton.setTitle("Copy Key", for: .normal)
    showQRButton.setTitle("Show QR", for: .normal)
  }
}
