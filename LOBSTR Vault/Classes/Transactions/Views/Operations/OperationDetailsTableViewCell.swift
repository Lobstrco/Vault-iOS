import UIKit

class OperationDetailsTableViewCell: UITableViewCell {
    
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var valueLabel: UILabel!
  
  func setData(title: String, value: String) {
    titleLabel.text = title
    valueLabel.text = value
  }
        
}
