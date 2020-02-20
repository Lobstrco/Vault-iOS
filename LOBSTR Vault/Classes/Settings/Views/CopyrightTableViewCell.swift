import UIKit

class CopyrightTableViewCell: UITableViewCell {

  @IBOutlet var copyrightLabel: UILabel!
  
  func setStaticString() {
    copyrightLabel.text = L10n.textSettingsCopyright    
  }
}
