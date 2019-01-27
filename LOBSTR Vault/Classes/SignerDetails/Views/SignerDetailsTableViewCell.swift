import UIKit

class SignerDetailsTableViewCell: UITableViewCell {

  @IBOutlet weak var publicKeyLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func setPublicKey(_ publicKey: String) {
    publicKeyLabel.text = publicKey
  }
}
