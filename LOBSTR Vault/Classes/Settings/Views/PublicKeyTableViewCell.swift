import UIKit

protocol PublicKeyTableViewCellView {
  func display(_ publicKey: String)
}

class PublicKeyTableViewCell: UITableViewCell, PublicKeyTableViewCellView {

  @IBOutlet var publicKeyLabel: UILabel!
  
  func display(_ publicKey: String) {
    self.publicKeyLabel.text = publicKey
  }
}
