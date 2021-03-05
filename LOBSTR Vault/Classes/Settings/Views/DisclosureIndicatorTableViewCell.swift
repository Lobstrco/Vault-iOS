import UIKit

protocol DisclosureIndicatorTableViewCellView {
  func setTitle(_ title: String)
  func setTextColor(_ color: UIColor)
  func setAttribute(_ attribute: NSMutableAttributedString)
  func setTextStatus(_ status: String)
}

class DisclosureIndicatorTableViewCell: UITableViewCell, DisclosureIndicatorTableViewCellView {
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var statusLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    statusLabel.isHidden = true
  }
  
  func setTitle(_ title: String) {
    titleLabel.text = title
  }
  
  func setTextColor(_ color: UIColor) {
    titleLabel.textColor = color
  }
  
  func setAttribute(_ attribute: NSMutableAttributedString) {
    titleLabel.attributedText = attribute
  }
  
  func setTextStatus(_ status: String) {
    statusLabel.isHidden = false
    statusLabel.text = status
  }
}
