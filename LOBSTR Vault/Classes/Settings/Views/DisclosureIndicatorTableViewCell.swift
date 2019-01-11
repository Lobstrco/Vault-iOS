import UIKit

protocol DisclosureIndicatorTableViewCellView {
  func setTitle(_ title: String)
}

class DisclosureIndicatorTableViewCell: UITableViewCell,
  DisclosureIndicatorTableViewCellView {
  
  func setTitle(_ title: String) {
    textLabel?.text = title
  }
}
