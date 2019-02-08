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
}
