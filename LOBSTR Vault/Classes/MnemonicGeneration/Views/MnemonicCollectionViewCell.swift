import UIKit

class MnemonicCollectionViewCell: UICollectionViewCell, MnemonicCellView {
  @IBOutlet var label: UILabel!
  
  override func awakeFromNib() {
    contentView.layer.borderColor = UIColor.gray.cgColor
    contentView.layer.borderWidth = 1
  }
  
  func display(title: String) {
    self.label.text = title
  }
  
  func copyToClipboard(mnemonic: String) {}
}
