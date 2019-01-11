import UIKit

protocol RightDetailTableViewCellView {
  func setTitle(_ title: String, detail: String)
}

class RightDetailTableViewCell: UITableViewCell, RightDetailTableViewCellView {
  func setTitle(_ title: String, detail: String) {
    textLabel?.text = title
    detailTextLabel?.text = detail
  }
}
