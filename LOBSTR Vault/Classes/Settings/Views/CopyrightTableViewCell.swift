import UIKit

class CopyrightTableViewCell: UITableViewCell {

  @IBOutlet var copyrightLabel: UILabel!
  
  func setStaticString() {
    let currentYear = Calendar.current.component(.year, from: Date())
    copyrightLabel.text = "©\(currentYear). " + L10n.textSettingsCopyright    
  }
}
