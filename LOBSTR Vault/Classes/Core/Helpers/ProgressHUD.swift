import UIKit

class ProgressHUD {
  var view: UIView?
  let isWhite: Bool
  let withBackground: Bool
  
  init(isWhite: Bool = false, withBackground: Bool = false) {
    self.isWhite = isWhite
    self.withBackground = withBackground
  }
  
  func display(onView : UIView) {
    guard view == nil else { return }
    
    let progressView = UIView.init(frame: onView.bounds)
    progressView.isUserInteractionEnabled = withBackground
    view = progressView
    if withBackground {
      progressView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.4)
      
    }
    
    let indicator = UIActivityIndicatorView.init(style: .whiteLarge)
    indicator.color = isWhite ? Asset.Colors.white.color : Asset.Colors.main.color
    indicator.startAnimating()
    indicator.center = progressView.center
    
    DispatchQueue.main.async {
      progressView.addSubview(indicator)
      onView.addSubview(progressView)
    }
  }
  
  func remove() {
    DispatchQueue.main.async {
      self.view?.removeFromSuperview()
      self.view = nil
    }
  }
}
