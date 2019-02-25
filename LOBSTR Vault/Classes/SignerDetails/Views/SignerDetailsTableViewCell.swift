import UIKit

protocol SignerDetailsTableViewCellDelegate: class {
  func menuButtonDidTap(in cell: SignerDetailsTableViewCell)
}

class SignerDetailsTableViewCell: UITableViewCell {

  @IBOutlet weak var publicKeyLabel: UILabel!
  
  weak var delegate: SignerDetailsTableViewCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func setPublicKey(_ publicKey: String) {
    publicKeyLabel.text = publicKey
  }
  
  @IBAction func menuButtonAction(_ sender: Any) {
    delegate?.menuButtonDidTap(in: self)
  }
  
}
