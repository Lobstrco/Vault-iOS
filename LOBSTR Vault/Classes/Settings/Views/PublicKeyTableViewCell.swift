import UIKit

protocol PublicKeyTableViewCellView {
  func setPublicKey(_ publicKey: String)
}

class PublicKeyTableViewCell: UITableViewCell, PublicKeyTableViewCellView {

  @IBOutlet var publicKeyLabel: UILabel!
  
  func setPublicKey(_ publicKey: String) {
    self.publicKeyLabel.text = publicKey
  }
}
