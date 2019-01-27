import UIKit

extension CALayer {
  
  func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
    
    let border = CALayer()
    
    switch edge {
    case UIRectEdge.top:
      border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
      break
    case UIRectEdge.bottom:
      //      border.frame = CGRect(0, CGRectGetHeight(self.frame) - thickness, UIScreen.main.bounds.width, thickness)
      break
    case UIRectEdge.left:
      border.frame = CGRect(x: 0, y: 0, width: thickness, height: 88)
      break
    case UIRectEdge.right:
      //      border.frame = CGRect(CGRectGetWidth(self.frame) - thickness, 0, thickness, CGRectGetHeight(self.frame))
      break
    default:
      break
    }
    
    border.backgroundColor = color.cgColor;
    
    self.addSublayer(border)
  }
}
