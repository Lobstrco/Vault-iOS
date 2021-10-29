import UIKit

enum OperationDetailsTableViewCellType: String {
  case flags
  case other
  case publicKey
  case assetCode
}

class OperationDetailsTableViewCell: UITableViewCell {
  var type: OperationDetailsTableViewCellType = .other
    
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var valueLabel: UILabel!
  
  func setData(title: String, value: String) {
    let numberOfLines = type == .flags ? 0 : 1
    valueLabel.numberOfLines = numberOfLines
    titleLabel.text = title
    valueLabel.text = value
  }
        
}
