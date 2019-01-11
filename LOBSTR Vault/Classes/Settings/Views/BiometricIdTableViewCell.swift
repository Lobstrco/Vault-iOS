import UIKit

protocol BiometricIDTableViewCellView {
  func setTitle(_ title: String)
  func setSwitch(_ isOn: Bool)
}

protocol BiometricIDTableViewCellDelegate: class {
  func biometricIDSwitchValueChanged(_ value: Bool)
}

class BiometricIDTableViewCell: UITableViewCell {
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var biometricIDSwitch: UISwitch!
  
  weak var delegate: BiometricIDTableViewCellDelegate?
  
  // MARK: - IBActions
  
  @IBAction func biometricIDSwitchAction(_ sender: UISwitch) {
    delegate?.biometricIDSwitchValueChanged(sender.isOn)
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
