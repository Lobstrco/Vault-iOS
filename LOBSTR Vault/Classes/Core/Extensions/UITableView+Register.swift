import UIKit

extension UITableView {
  func registerNib<T: UITableViewCell>(_: T.Type) {
    let nib = UINib(nibName: T.nibName, bundle: nil)
    register(nib, forCellReuseIdentifier: T.reuseIdentifier)
  }
  
  func registerNibForHeaderFooter<T: UIView>(_: T.Type) {
    let nib = UINib(nibName: T.nibName, bundle: nil)
    register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
  }
  
  func registerClass<T: UITableViewCell>(_: T.Type) {
    register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
  }
}
