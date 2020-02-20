import UIKit

protocol RightDetailTableViewCellView {
  func setTitle(_ title: String, detail: String)
}

class RightDetailTableViewCell: UITableViewCell, RightDetailTableViewCellView {
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var detailLabel: UILabel!
  
  func setTitle(_ title: String, detail: String) {
    titleLabel?.text = title
    detailLabel?.text = detail
  }
}
