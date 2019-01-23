import UIKit

class TransactionListTableViewCell: UITableViewCell, TransactionListCellView {
  
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var operationTypeLabel: UILabel!

  @IBOutlet weak var content: UIView!
  
  // MARK: - TransactionListCellView
  
  func set(date: String?, operationType: String?) {
    dateLabel.text = date
    operationTypeLabel.text = operationType
  }
}
