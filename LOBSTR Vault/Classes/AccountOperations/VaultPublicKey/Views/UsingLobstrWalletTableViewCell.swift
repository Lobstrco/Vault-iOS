import UIKit

protocol UsingLobstrWalletTableViewCellDelegate: class {
  func actionButtonWasPressed()
}

class UsingLobstrWalletTableViewCell: UITableViewCell {
  
  @IBOutlet var shadowView: UIView!
  @IBOutlet var infoContainerView: UIView!
  
  @IBOutlet var actionButton: UIButton!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var descriptionLabel: UILabel!
  
  weak var delegate: UsingLobstrWalletTableViewCellDelegate?
  
  // MARK: - Lifecycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
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
  
  // MARK: - IBActions
  
  @IBAction func openLobstrAppButtonAction(_ sender: UIButton) {
    delegate?.actionButtonWasPressed()
  }
  
  func setInformationAccording(_ type: LobstrCheckResult) {
    switch type {
    case .notInstalled:
      titleLabel.text = "Install LOBSTR wallet"
      descriptionLabel.text = "Vault signer app works best with LOBSTR wallet. Install LOBSTR to enable multisig and use advanced features."
      actionButton.setTitle("Download LOBSTR", for: .normal)
    case .installed:
      titleLabel.text = "Use Vault with LOBSTR on this device"
      descriptionLabel.text = "Open LOBSTR to add this device as a signer for your Stellar account and use advanced multisignature capabilities."
      actionButton.setTitle("Open LOBSTR Wallet", for: .normal)
    }
  }
}
