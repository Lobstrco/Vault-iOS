import UIKit

class OperationTableViewCell: UITableViewCell {

  @IBOutlet weak var operationLabel: UILabel!  
  
  func setOperationTitle(_ title: String) {
    operationLabel.text = title 
  }

}
