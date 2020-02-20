import UIKit

class PinDotView: UIView, Shakeable {
  
  private var dotsContainer: UIStackView!
  
  let numberOfDots = 6
  let sizeOfDot: CGFloat = 16
  
  var colors: (fillColor: UIColor, outColor: UIColor)?

  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }
  
  // MARK: - Public
  
  func setupAppearance(with colors: (fillColor: UIColor, outColor: UIColor)) {
    self.colors = colors
    
    for dot in dotsContainer.arrangedSubviews {
      dot.backgroundColor = colors.outColor
    }
  }
  
  func clearPinDots() {
    for i in 0..<numberOfDots {
      clearPinDot(at: i)
    }
  }
  
  func clearPinDot(at index: Int) {
    let circleForClear = dotsContainer.arrangedSubviews[index]
    circleForClear.backgroundColor = colors?.outColor
  }

  func fillPinDot(at index: Int) {
    let circle = dotsContainer.arrangedSubviews[index]
    circle.backgroundColor = colors?.fillColor
  }
  
  // MARK: - Private
  
  private func setupView() {
    dotsContainer = UIStackView(frame: self.bounds)
    self.addSubview(dotsContainer)
    
    dotsContainer.distribution = .equalSpacing
    dotsContainer.axis = .horizontal
    
    for _ in 0..<numberOfDots {
      let dot = UIView()
      dot.widthAnchor.constraint(equalToConstant: sizeOfDot).isActive = true
      dot.layer.cornerRadius = sizeOfDot / 2
      
      dotsContainer.addArrangedSubview(dot)
    }
  }
}
