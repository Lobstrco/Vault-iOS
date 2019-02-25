import UIKit

protocol BiometricIDTableViewCellView {
  func setTitle(_ title: String)
  func setSwitch(_ isOn: Bool)
}

enum SwitchType {
  case biometricID
  case notifications
}

protocol BiometricIDTableViewCellDelegate: class {
  func biometricIDSwitchValueChanged(_ value: Bool, type: SwitchType)
}

class BiometricIDTableViewCell: UITableViewCell {
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var biometricIDSwitch: UISwitch!
  
  var switchType: SwitchType?
  weak var delegate: BiometricIDTableViewCellDelegate?
  
  // MARK: - IBActions
  
  @IBAction func biometricIDSwitchAction(_ sender: UISwitch) {
    if let switchType = switchType {
      delegate?.biometricIDSwitchValueChanged(sender.isOn, type: switchType)
    }
  }
}

// MARK: - BiometricIDTableViewCellView

extension BiometricIDTableViewCell: BiometricIDTableViewCellView {
  func setTitle(_ title: String) {
    titleLabel.text = title
  }
  
  func setSwitch(_ isOn: Bool) {
    biometricIDSwitch.isOn = isOn
  }
}
