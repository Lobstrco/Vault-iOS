import Foundation
import UIKit

struct AppearanceHelper {
  
  static func set(_ navigationController: UINavigationController?) {
    navigationController?.navigationBar.tintColor = Asset.Colors.main.color
    navigationController?.navigationBar.barTintColor = Asset.Colors.white.color
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
  }
  
  static func setBackButton(in navigationController: UINavigationController?) {
    navigationController?.navigationBar.topItem?.title = ""
  }
  
  static func setHelpButton(to navigationItem: UINavigationItem, selector: Selector?, vc: UIViewController) {
    let rightBarButtonItem = UIBarButtonItem.init(title: L10n.buttonTitleNext,
                                                  style: .plain,
                                                  target: vc,
                                                  action: selector)
    
    navigationItem.rightBarButtonItem = rightBarButtonItem
  }
  
  static func set(_ button: UIButton, with title: String) {
    button.layer.cornerRadius = 4
    button.setTitle(title, for: .normal)
  }
}
