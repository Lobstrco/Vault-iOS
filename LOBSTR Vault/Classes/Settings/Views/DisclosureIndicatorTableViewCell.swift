import UIKit

protocol DisclosureIndicatorTableViewCellView {
  func setTitle(_ title: String)
  func setTextColor(_ color: UIColor)
  func setAttribute(_ attribute: NSMutableAttributedString)
}

class DisclosureIndicatorTableViewCell: UITableViewCell, DisclosureIndicatorTableViewCellView {
  
  @IBOutlet var titleLabel: UILabel!
  
  func setTitle(_ title: String) {
    titleLabel?.text = title
  }
  
  func setTextColor(_ color: UIColor) {
    titleLabel?.textColor = color
  }
  
  func setAttribute(_ attribute: NSMutableAttributedString) {
    titleLabel?.attributedText = attribute
  }
}
