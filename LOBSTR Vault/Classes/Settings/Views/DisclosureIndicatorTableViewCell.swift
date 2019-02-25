import UIKit

protocol DisclosureIndicatorTableViewCellView {
  func setTitle(_ title: String)
  func setTextColor(_ color: UIColor)
}

class DisclosureIndicatorTableViewCell: UITableViewCell,
  DisclosureIndicatorTableViewCellView {
  
  func setTitle(_ title: String) {
    textLabel?.text = title    
  }
  
  func setTextColor(_ color: UIColor) {
    textLabel?.textColor = color
  }
}
