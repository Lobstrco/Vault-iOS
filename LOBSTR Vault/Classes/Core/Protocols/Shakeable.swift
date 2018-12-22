import UIKit

protocol Shakeable { }

extension Shakeable where Self: UIView {
  func shake() {
    let keyPath = "position"
    let animation = CABasicAnimation(keyPath: keyPath)
    animation.duration = 0.05
    animation.repeatCount = 4
    animation.autoreverses = true
    animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 4.0,
                                                   y: self.center.y))
    animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 4.0,
                                                 y: self.center.y))
    
    self.layer.add(animation, forKey: keyPath)
  }
}
