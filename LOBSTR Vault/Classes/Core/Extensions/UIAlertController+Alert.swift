import UIKit

extension UIAlertController {
  static func defaultAlert(for error: Error, presentingViewController: UIViewController) {
    guard let infoError = error as? ErrorDisplayable else { return }
    
    let controller = UIAlertController(title: infoError.displayData.titleKey.localized(),
                                       message: infoError.displayData.messageKey.localized(), preferredStyle: .alert)
    
    let action = UIAlertAction(title: L10n.buttonTitleOk, style: .default, handler: nil)
    controller.addAction(action)
    
    presentingViewController.present(controller, animated: true, completion: nil)
  }
  
  static func defaultAlert(with error: String, presentingViewController: UIViewController) {
    let controller = UIAlertController(title: "",
                                       message: error,
                                       preferredStyle: .alert)
    
    let action = UIAlertAction(title: L10n.buttonTitleOk, style: .default, handler: nil)
    controller.addAction(action)
    
    presentingViewController.present(controller, animated: true, completion: nil)
  }
  
  static func screenshotTakenAlert(presentingViewController: UIViewController) {
    let alert = UIAlertController(title: L10n.screenshotWarningTitle,
                                  message: L10n.screenshotWarningDescription,
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleOk, style: .default))

    presentingViewController.present(alert, animated: true, completion: nil)
  }
}
