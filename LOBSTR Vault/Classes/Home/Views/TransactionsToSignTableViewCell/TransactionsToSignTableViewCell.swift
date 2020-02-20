//

import UIKit

protocol TransactionsToSignTableViewCellDelegate: class {
  func viewTransactionListDidPress()
}

class TransactionsToSignTableViewCell: UITableViewCell {
  
  @IBOutlet var transactionNumberLabel: UILabel!
  @IBOutlet var transactionListButton: UIButton!
  @IBOutlet var transactionsToSignLabel: UILabel!
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  
  weak var delegate: TransactionsToSignTableViewCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    AppearanceHelper.set(transactionListButton,
                         with: L10n.buttonTitleViewTransactionsList)
    
    transactionsToSignLabel.text = L10n.textTransactionsToSign
  }
  
  // MARK: - IBActions
  
  @IBAction func transactionListButtonAction(_ sender: Any) {
    delegate?.viewTransactionListDidPress()
  }

}
