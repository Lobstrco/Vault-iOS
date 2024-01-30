import UIKit

protocol PublicKeyTableViewCellView {
  func configure(_ title: String, _ actionDescription: String)
}

class PublicKeyTableViewCell: UITableViewCell, PublicKeyTableViewCellView {
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var actionDescriptionLabel: UILabel!

  func configure(_ title: String, _ actionDescription: String) {
    titleLabel.text = title
    actionDescriptionLabel.text = actionDescription
  }
}
