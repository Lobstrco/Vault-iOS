import UIKit

protocol ReusableView: AnyObject { }

extension ReusableView where Self: UIView {
  static var reuseIdentifier: String {
    return String(describing: self)
  }
}

extension UIView: ReusableView { }
