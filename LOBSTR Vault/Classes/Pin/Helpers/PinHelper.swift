import Foundation
import UIKit

struct PinHelper {
  static func tryToShowPinEnterViewController() {
    switch UserDefaultsHelper.accountStatus {
    case .createdByDefault:
      openPinEnterViewController()
    default:
      break
    }

  }
  static func openPinEnterViewController() {
    if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
      let pinViewController = PinEnterViewController.createFromStoryboard()
      pinViewController.mode = .enterPin
      let navigationController = UINavigationController(rootViewController: pinViewController)
      navigationController.modalPresentationStyle = .overFullScreen
      navigationController.navigationBar.isHidden = true
      window.rootViewController?.present(navigationController, animated: false, completion: nil)
    }
  }
}
