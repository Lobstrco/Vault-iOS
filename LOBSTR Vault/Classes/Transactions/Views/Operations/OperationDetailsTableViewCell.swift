import UIKit

enum OperationDetailsTableViewCellType: String {
  case flags
  case other
  case publicKey
  case assetCode
  case claimBetween
  case memo
}

class OperationDetailsTableViewCell: UITableViewCell {
  var type: OperationDetailsTableViewCellType = .other
    
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var valueLabel: UILabel!
  
  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)
    if highlighted && type != .other {
      backgroundColor = Asset.Colors.grayOpacity15.color
    } else {
      backgroundColor = Asset.Colors.white.color
    }
  }
  
  func setData(title: String, value: String) {
    let numberOfLines = type == .flags || type == .claimBetween ? 0 : 1
    let lineBreakMode: NSLineBreakMode = type == .memo ? .byTruncatingMiddle : .byTruncatingTail
    valueLabel.numberOfLines = numberOfLines
    titleLabel.text = title
    valueLabel.lineBreakMode = lineBreakMode
    valueLabel.text = value
  }
        
}
