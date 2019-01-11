import UIKit

class TransactionListTableViewCell: UITableViewCell, TransactionListCellView {
  
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var operationTypeLabel: UILabel!

  // MARK: - TransactionListCellView
  
  func set(date: String?, operationType: String?) {
    dateLabel.text = date
    operationTypeLabel.text = operationType
  }
}
