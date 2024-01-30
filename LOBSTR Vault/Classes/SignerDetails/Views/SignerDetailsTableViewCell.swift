import Kingfisher
import UIKit

protocol SignerDetailsTableViewCellDelegate: AnyObject {
  func moreDetailsButtonWasPressed(in cell: SignerDetailsTableViewCell)
}

class SignerDetailsTableViewCell: UITableViewCell {
  @IBOutlet var publicKeyLabel: UILabel!
  @IBOutlet var signerFederationLabel: UILabel! {
    didSet {
      signerFederationLabel.lineBreakMode = .byTruncatingTail
    }
  }
  
  @IBOutlet var identiconView: IdenticonView!
  
  weak var delegate: SignerDetailsTableViewCellDelegate?
  var publicKey: String?
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func set(_ signedAccount: SignedAccount) {
    if let address = signedAccount.address {
      identiconView.loadIdenticon(publicAddress: address)
    }
    
    publicKey = signedAccount.address
    publicKeyLabel.text = signedAccount.address?.getTruncatedPublicKey() ?? "unknown address"
    
    var nicknameValue = ""
    var federationValue = ""
    
    if let nickName = signedAccount.nickname, !nickName.isEmpty {
      nicknameValue = nickName
    } else {
      if let federation = signedAccount.federation, !federation.isEmpty {
        federationValue = federation
      } else {
        signerFederationLabel.isHidden = true
        publicKeyLabel.font = UIFont.boldSystemFont(ofSize: 12)
        publicKeyLabel.textColor = Asset.Colors.black.color
        return
      }
    }
    
    let text = !nicknameValue.isEmpty ? nicknameValue : federationValue
        
    publicKeyLabel.font = UIFont.systemFont(ofSize: 13)
    publicKeyLabel.textColor = Asset.Colors.gray.color
    signerFederationLabel.text = text
    signerFederationLabel.isHidden = false
  }
  
  @IBAction func menuButtonAction(_ sender: Any) {
    delegate?.moreDetailsButtonWasPressed(in: self)
  }
}
