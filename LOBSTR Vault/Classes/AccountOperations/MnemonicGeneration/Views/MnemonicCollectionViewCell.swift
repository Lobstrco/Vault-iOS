import UIKit

class MnemonicCollectionViewCell: UICollectionViewCell, MnemonicCellView {
  
  @IBOutlet var titleLabel: UILabel!
  
  // MARK: - MnemonicCellView
  
  func set(title: String) {
    self.titleLabel.text = title
  }
  
  override var isSelected: Bool {
    didSet{
      setAppearance()
    }
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    backgroundColor = isSelected ? Asset.Colors.background.color : Asset.Colors.main.color
    titleLabel.isHidden = isSelected
    if isSelected {
      AppearanceHelper.setDashBorders(for: self, with: Asset.Colors.gray.color.cgColor)
    } else {
      AppearanceHelper.removeDashBorders(from: self)
    }
    
  }
}
