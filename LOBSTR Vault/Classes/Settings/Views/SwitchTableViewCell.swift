import UIKit

protocol SwitchTableViewCellView {
  func setTitle(_ title: String)
  func setSwitch(_ isOn: Bool)
}

enum SwitchType {
  case biometricID
  case notifications
}

protocol SwitchTableViewCellDelegate: AnyObject {
  func switchValueChanged(_ value: Bool, type: SwitchType)
}

class SwitchTableViewCell: UITableViewCell {
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var switchElement: UISwitch!
  
  var switchType: SwitchType?
  weak var delegate: SwitchTableViewCellDelegate?
  
  // MARK: - IBActions
  
  @IBAction func switchAction(_ sender: UISwitch) {
    if let switchType = switchType {
      delegate?.switchValueChanged(sender.isOn, type: switchType)
    }
  }
}

// MARK: - BiometricIDTableViewCellView

extension SwitchTableViewCell: SwitchTableViewCellView {
  func setTitle(_ title: String) {
    titleLabel.text = title
  }
  
  func setSwitch(_ isOn: Bool) {
    switchElement.isOn = isOn
  }
}
