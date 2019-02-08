import UIKit
import PKHUD

open class PKHUDSuccessViewCustom: PKHUDSquareBaseView, PKHUDAnimating {
  
  public let backgroundView: UIView = {
    let new = UIView()
    new.backgroundColor = UIColor.white
    new.alpha = 1
    return new
  }()
  
  var checkmarkShapeLayer: CAShapeLayer = {
    let checkmarkPath = UIBezierPath()
    checkmarkPath.move(to: CGPoint(x: 4.0, y: 27.0))
    checkmarkPath.addLine(to: CGPoint(x: 34.0, y: 56.0))
    checkmarkPath.addLine(to: CGPoint(x: 88.0, y: 0.0))
    
    let layer = CAShapeLayer()
    layer.frame = CGRect(x: 3.0, y: 3.0, width: 88.0, height: 56.0)
    layer.path = checkmarkPath.cgPath
    
    #if swift(>=4.2)
    layer.fillMode    = .forwards
    layer.lineCap     = .round
    layer.lineJoin    = .round
    #else
    layer.fillMode    = kCAFillModeForwards
    layer.lineCap     = kCALineCapRound
    layer.lineJoin    = kCALineJoinRound
    #endif
    
    layer.fillColor   = nil
    layer.strokeColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0).cgColor
    layer.lineWidth   = 6.0
    return layer
  }()
  
  public init(title: String? = nil, subtitle: String? = nil) {
    super.init(title: title, subtitle: subtitle)
    addSubview(backgroundView)
    sendSubviewToBack(backgroundView)
    layer.addSublayer(checkmarkShapeLayer)
    checkmarkShapeLayer.position = layer.position
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    addSubview(backgroundView)
    layer.addSublayer(checkmarkShapeLayer)
    checkmarkShapeLayer.position = layer.position
  }
  
  open func startAnimation() {
    let checkmarkStrokeAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
    checkmarkStrokeAnimation.values = [0, 1]
    checkmarkStrokeAnimation.keyTimes = [0, 1]
    checkmarkStrokeAnimation.duration = 0.35
    
    checkmarkShapeLayer.add(checkmarkStrokeAnimation, forKey: "checkmarkStrokeAnim")
  }
  
  open func stopAnimation() {
    checkmarkShapeLayer.removeAnimation(forKey: "checkmarkStrokeAnimation")
  }
  
  override open func layoutSubviews() {
    super.layoutSubviews()
    
    let margin: CGFloat = PKHUD.sharedHUD.leadingMargin + PKHUD.sharedHUD.trailingMargin
    let viewWidth = bounds.size.width - 2 * margin
    let viewHeight = bounds.size.height
    
    backgroundView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: viewWidth, height: viewHeight))
  }
}
