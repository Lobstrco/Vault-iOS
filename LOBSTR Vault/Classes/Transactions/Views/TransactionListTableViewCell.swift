import UIKit

class TransactionListTableViewCell: UITableViewCell, TransactionListCellView {
  
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var sourceAccountLabel: UILabel!
  @IBOutlet var operationTypeLabel: UILabel!
  @IBOutlet var statusLabel: UILabel!
  @IBOutlet weak var content: UIView!
  
  private var borderView: UIView!
  
  // MARK: - TransactionListCellView
  
  override func awakeFromNib() {
    selectionStyle = UITableViewCell.SelectionStyle.none
    
    content.layer.shadowColor = UIColor.black.cgColor
    content.layer.shadowOffset = CGSize(width: 0, height: 2)
    content.layer.shadowOpacity = 0.1
    content.layer.shadowRadius = 2
    
    setStaticString()
  }
  
  override func prepareForReuse() {
    borderView.removeFromSuperview()
  }
  
  func set(date: String?, operationType: String?, sourceAccount: String, isValid: Bool) {
    dateLabel.text = date
    operationTypeLabel.text = operationType
    sourceAccountLabel.text = sourceAccount
    setValidationAppearance(isValid)
    setStatusLabel(isValid)
  }
  
  private func setStaticString() {
    statusLabel.text = L10n.textTransactionInvalidLabel
  }
  
  private func setValidationAppearance(_ isValid: Bool) {
    borderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 81))
    borderView.backgroundColor = Asset.Colors.white.color
    borderView.clipsToBounds = true
    borderView.layer.cornerRadius = 6
    borderView.layer.borderWidth = 1
    borderView.layer.borderColor = Asset.Colors.cellBorder.color.cgColor
    
    let borderColor = isValid ? Asset.Colors.main.color : Asset.Colors.gray.color
    borderView.layer.addBorder(edge: .left, color: borderColor, thickness: 8)
    
    content.addSubview(borderView)
    content.sendSubviewToBack(borderView)
  }
  
  private func setStatusLabel(_ isValid: Bool) {
    statusLabel.isHidden = isValid ? true : false
  }
}
