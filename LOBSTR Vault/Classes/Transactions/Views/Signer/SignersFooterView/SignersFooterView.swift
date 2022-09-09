//

import UIKit

class SignersFooterView: UITableViewHeaderFooterView {
  @IBOutlet var messageLabel: UILabel! {
    didSet {
      switch UIDevice().type {
      case .iPhone5, .iPhone5C, .iPhone5S, .iPhoneSE:
        messageLabel.font = UIFont.systemFont(ofSize: 9.0)
      case .iPhone6, .iPhone6S, .iPhone7, .iPhone8, .iPhoneSE2, .iPhoneSE3, .iPhoneX, .iPhoneXS, .iPhone11Pro, .iPhone12Mini, .iPhone13Mini:
        messageLabel.font = UIFont.systemFont(ofSize: 11.0)
      default:
        messageLabel.font = UIFont.systemFont(ofSize: 12.0)
      }
    }
  }

  static let height: CGFloat = 32.0
}
