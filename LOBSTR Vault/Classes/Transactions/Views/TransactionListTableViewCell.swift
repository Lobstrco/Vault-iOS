import UIKit
import Kingfisher

class TransactionListTableViewCell: UITableViewCell, TransactionListCellView {
  
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var sourceAccountLabel: UILabel!
  @IBOutlet var operationTypeLabel: UILabel!
  @IBOutlet var statusLabel: UILabel!
  @IBOutlet var content: UIView!
  @IBOutlet var identiconView: IdenticonView!
  @IBOutlet var dateStackViewRightConstraint: NSLayoutConstraint!
  @IBOutlet var dateStackViewLeftConstraint: NSLayoutConstraint!
  
  
  private var borderView: UIView!
  
  var viewModel: ViewModel? {
    didSet {
      guard let model = viewModel else { return }
      dateLabel.text = model.date
      operationTypeLabel.text = model.operationType
      if let federationName = model.federation {
        sourceAccountLabel.text = federationName
      } else {
        let numberOfCharactersForTruncate = TransactionHelper.getNumberOfCharactersForTruncate()
        sourceAccountLabel.text = model.sourceAccount.getTruncatedPublicKey(numberOfCharacters: numberOfCharactersForTruncate)
      }
      statusLabel.text = L10n.textTransactionInvalidLabel
      
      setValidationAppearance(model.isTransactionValid)
      setStatusLabel(model.isTransactionValid)
      identiconView.loadIdenticon(publicAddress: model.sourceAccount)
    }
  }
  
  // MARK: - TransactionListCellView
  
  override func awakeFromNib() {
    setupUI()
  }
  
  override func prepareForReuse() {
    borderView.removeFromSuperview()
  }
}

// MARK: - Private

private extension TransactionListTableViewCell {
  func setupUI() {
    selectionStyle = UITableViewCell.SelectionStyle.none
    content.layer.shadowColor = UIColor.black.cgColor
    content.layer.shadowOffset = CGSize(width: 0, height: 2)
    content.layer.shadowOpacity = 0.1
    content.layer.shadowRadius = 2
    dateLabel.textAlignment = .right
    
    switch UIDevice().type {
    case .iPhone5, .iPhone5C, .iPhone5S, .iPhoneSE:
      dateStackViewLeftConstraint.constant = 3
      dateStackViewRightConstraint.constant = 13
    default:
      dateStackViewLeftConstraint.constant = 5
      dateStackViewRightConstraint.constant = 16
    }
  }
  
  func setValidationAppearance(_ isValid: Bool) {
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
  
  func setStatusLabel(_ isValid: Bool) {
    statusLabel.isHidden = isValid ? true : false
  }
}

// MARK: ViewModel

extension TransactionListTableViewCell {
  struct ViewModel: Equatable {
    let date: String
    let operationType: String
    let sourceAccount: String
    var federation: String?
    let isTransactionValid: Bool
  }
}
