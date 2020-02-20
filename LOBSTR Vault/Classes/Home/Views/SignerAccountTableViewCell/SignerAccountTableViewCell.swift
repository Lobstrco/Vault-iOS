import UIKit

protocol SignerAccountDelegate {
  func moreDetailsButtonWasPressed(in cell: SignerAccountTableViewCell)
  func longTapWasActivated(in cell: SignerAccountTableViewCell)
}

class SignerAccountTableViewCell: UITableViewCell {
  @IBOutlet var signerPublicAddressLabel: UILabel!
  @IBOutlet var signerFederationLabel: UILabel!
  
  @IBOutlet var identiconView: IdenticonView!
  @IBOutlet var separatorView: UIView!
  
  @IBOutlet var shadowView: UIView!
  @IBOutlet var infoContainerView: UIView!
  
  var delegate: SignerAccountDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    shadowView.layer.shadowOpacity = 0.2
    shadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
    shadowView.layer.shadowRadius = 4
    shadowView.layer.shadowColor = UIColor.black.cgColor
    shadowView.layer.masksToBounds = false
    
    let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    lpgr.minimumPressDuration = 0.5
    lpgr.delaysTouchesBegan = true
    lpgr.delegate = self
    self.addGestureRecognizer(lpgr)
  }
  
  @IBAction func moreDetailsButtonAction() {
    delegate?.moreDetailsButtonWasPressed(in: self)
  }
  
  @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
    if gestureReconizer.state == UIGestureRecognizer.State.ended {
      delegate?.longTapWasActivated(in: self)
    }
  }
}

extension SignerAccountTableViewCell {
  func set(_ signedAccount: SignedAccount) {
    if let address = signedAccount.address {
      identiconView.loadIdenticon(publicAddress: address)
    }
        
    signerPublicAddressLabel.textColor = Asset.Colors.black.color
    signerPublicAddressLabel.font = UIFont.boldSystemFont(ofSize: 13)
    signerPublicAddressLabel.text = signedAccount.address?.getTruncatedPublicKey(numberOfCharacters: 10) ?? "unknown address"
    
    guard let federation = signedAccount.federation else {
      signerFederationLabel.isHidden = true
      return
    }
    
    signerPublicAddressLabel.font = UIFont.systemFont(ofSize: 13)
    signerPublicAddressLabel.textColor = Asset.Colors.gray.color
    signerFederationLabel.text = federation
    signerFederationLabel.isHidden = false
  }
}
