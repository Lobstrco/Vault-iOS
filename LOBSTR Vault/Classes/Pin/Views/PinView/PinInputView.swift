import UIKit

class PinInputView: UIView, Shakeable {
  
  @IBOutlet var contentView: UIView!
  @IBOutlet var pinDotViews: [UIView]!
  
  // MARK: - Init
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    Bundle.main.loadNibNamed("PinInputView", owner: self, options: nil)
    addSubview(contentView)
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
  
  func clearPinDots() {
    for i in 0..<pinDotViews.count {
      clearPinDot(at: i)
    }
  }
  
  func clearPinDot(at index: Int) {
    let circleForClear = pinDotViews[index]
    circleForClear.layer.borderWidth = 2
    circleForClear.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    circleForClear.layer.cornerRadius = 10
    circleForClear.backgroundColor = .clear
  }
  
  func fillPinDot(at index: Int) {
    let circle = pinDotViews[index]
    circle.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    circle.layer.cornerRadius = 10
    circle.layer.borderWidth = 0
  }
}
