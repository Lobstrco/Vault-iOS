import UIKit

protocol BiometricIdTableViewCellView {
  func setTitle(_ title: String)
}

class BiometricIdTableViewCell: UITableViewCell, BiometricIdTableViewCellView {
  
  @IBOutlet var titleLabel: UILabel!
  
  func setTitle(_ title: String) {
    titleLabel.text = title
  }
}
