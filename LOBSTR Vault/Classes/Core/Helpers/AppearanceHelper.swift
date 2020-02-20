import Foundation
import UIKit

struct AppearanceHelper {
  
  static func setNavigationApperance(_ navigationController: UINavigationController) {
    navigationController.navigationBar.prefersLargeTitles = true
    navigationController.navigationBar.tintColor = Asset.Colors.main.color
    navigationController.navigationBar.barTintColor = Asset.Colors.white.color
    navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController.navigationBar.shadowImage = UIImage()
    navigationController.navigationBar.topItem?.title = ""
  }
  
  static func set(_ navigationController: UINavigationController?) {
    navigationController?.navigationBar.tintColor = Asset.Colors.main.color
    navigationController?.navigationBar.barTintColor = Asset.Colors.white.color
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
  
  static func setDashBorders(for view: UIView, with color: CGColor) {
    let viewBorder = CAShapeLayer()
    viewBorder.strokeColor = color
    viewBorder.lineDashPattern = [6, 2]
    viewBorder.frame = view.bounds
    viewBorder.fillColor = nil
    viewBorder.path = UIBezierPath(rect: view.bounds).cgPath
    view.layer.addSublayer(viewBorder)
  }
  
  static func changeDashBorderColor(for view: UIView, with color: CGColor) {
    let viewBorder = view.layer.sublayers?.last as? CAShapeLayer    
    viewBorder?.strokeColor = color
  }
  
  static func removeDashBorders(from view: UIView) {
    let viewBorder = view.layer.sublayers?.last as? CAShapeLayer
    viewBorder?.removeFromSuperlayer()
  }
}

extension UINavigationController {

    func setStatusBar(backgroundColor: UIColor) {
        let statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = backgroundColor
        view.addSubview(statusBarView)
    }

}
