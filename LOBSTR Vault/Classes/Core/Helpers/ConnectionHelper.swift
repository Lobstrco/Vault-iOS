import Foundation
import UIKit

struct ConnectionHelper {
  static func checkConnection(_ controller: UIViewController) -> Bool {
    guard UIDevice.isConnectedToNetwork else {
      let alert = UIAlertController(title: L10n.internetConnectionErrorTitle, message: L10n.internetConnectionErrorDescription, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: L10n.buttonTitleOk, style: .cancel))

      controller.present(alert, animated: true, completion: nil)
      return false
    }
    return true
  }
}
