import UIKit

protocol SignerAccountDelegate: AnyObject {
  func moreDetailsButtonWasPressed(in cell: SignerAccountTableViewCell)
  func longTapWasActivated(in cell: SignerAccountTableViewCell)
}

class SignerAccountTableViewCell: UITableViewCell {
  @IBOutlet var signerPublicAddressLabel: UILabel!
  @IBOutlet var signerFederationLabel: UILabel! {
    didSet {
      signerFederationLabel.lineBreakMode = .byTruncatingTail
    }
  }
  
  @IBOutlet var identiconView: IdenticonView!
  @IBOutlet var separatorView: UIView!
  
  weak var delegate: SignerAccountDelegate?
  var publicKey: String?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    lpgr.minimumPressDuration = 0.5
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
    publicKey = signedAccount.address
    if let address = signedAccount.address {
      identiconView.loadIdenticon(publicAddress: address)
    }
        
    signerPublicAddressLabel.textColor = Asset.Colors.black.color
    signerPublicAddressLabel.font = UIFont.boldSystemFont(ofSize: 13)
    signerPublicAddressLabel.text = signedAccount.address?.getTruncatedPublicKey() ?? "unknown address"
    
    var nicknameValue = ""
    var federationValue = ""
    
    if let nickName = signedAccount.nickname, !nickName.isEmpty {
      nicknameValue = nickName
    } else {
      if let federation = signedAccount.federation, !federation.isEmpty {
        federationValue = federation
      } else {
        signerFederationLabel.isHidden = true
        return
      }
    }
    
    let text = !nicknameValue.isEmpty ? nicknameValue : federationValue
        
    signerPublicAddressLabel.font = UIFont.systemFont(ofSize: 13)
    signerPublicAddressLabel.textColor = Asset.Colors.gray.color
    signerFederationLabel.text = text
    signerFederationLabel.isHidden = false
  }
}
