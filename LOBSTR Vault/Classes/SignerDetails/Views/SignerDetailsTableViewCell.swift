import UIKit
import Kingfisher

protocol SignerDetailsTableViewCellDelegate: class {
  func moreDetailsButtonWasPressed(in cell: SignerDetailsTableViewCell)
}

class SignerDetailsTableViewCell: UITableViewCell {

  @IBOutlet weak var publicKeyLabel: UILabel!
  @IBOutlet var signerFederationLabel: UILabel!
  
  @IBOutlet var identiconView: IdenticonView!
  
  weak var delegate: SignerDetailsTableViewCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func set(_ signedAccount: SignedAccount) {
    if let address = signedAccount.address {
      identiconView.loadIdenticon(publicAddress: address)
    }
    
    publicKeyLabel.text = signedAccount.address?.getTruncatedPublicKey(numberOfCharacters: 10) ?? "unknown address"
    
    guard let federation = signedAccount.federation else {
      signerFederationLabel.isHidden = true
      return
    }
    
    publicKeyLabel.font = UIFont.systemFont(ofSize: 13)
    publicKeyLabel.textColor = Asset.Colors.gray.color
    signerFederationLabel.text = federation
    signerFederationLabel.isHidden = false
  }
  
  @IBAction func menuButtonAction(_ sender: Any) {
    delegate?.moreDetailsButtonWasPressed(in: self)
  }
  
}
