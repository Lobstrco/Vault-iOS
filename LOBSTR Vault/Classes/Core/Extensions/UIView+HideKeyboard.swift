//

import Foundation
import UIKit

extension UIView {
  func hideKeyboardWhenTapped() {
    let gestureDetector = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    gestureDetector.cancelsTouchesInView = false
    addGestureRecognizer(gestureDetector)
  }
  
  @objc func hideKeyboard() {
    self.endEditing(true)
  }
}
