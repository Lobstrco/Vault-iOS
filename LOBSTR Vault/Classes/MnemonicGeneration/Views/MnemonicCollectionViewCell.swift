import UIKit

class MnemonicCollectionViewCell: UICollectionViewCell, MnemonicCellView {
  @IBOutlet var label: UILabel!  
  
  func display(title: String) {
    self.label.text = title
  }
  
  func copyToClipboard(mnemonic: String) {}
}
