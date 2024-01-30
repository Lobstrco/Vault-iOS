import UIKit

protocol NibloadableView: AnyObject {}

extension NibloadableView where Self: UIView {
  static var nibName: String {
    return String(describing: self)
  }
}

extension UIView: NibloadableView { }
