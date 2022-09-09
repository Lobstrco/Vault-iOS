import UIKit

enum NumberPadButton {
  case number(Int)
  case left, right
  case undefined
}

protocol NumberPadViewDelegate: AnyObject {
  func numberPadButtonWasPressed(button: NumberPadButton)
}

class NumberPadView: UIView {
  @IBOutlet var contentView: UIView!
  @IBOutlet var buttons: [UIButton]!
  @IBOutlet var leftButton: UIButton!
  @IBOutlet var rightButton: UIButton!

  weak var delegate: NumberPadViewDelegate?

  // MARK: - Init

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    Bundle.main.loadNibNamed("NumberPadView", owner: self, options: nil)
    addSubview(contentView)
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    rightButtonEnable(false)
  }

  // MARK: - IBActions

  @IBAction func buttonAction(_ sender: Any) {
    guard let button = sender as? UIButton else { return }

    var pressedButton: NumberPadButton

    switch button {
    case _ where button == buttons[0]: pressedButton = .number(1)
    case _ where button == buttons[1]: pressedButton = .number(2)
    case _ where button == buttons[2]: pressedButton = .number(3)
    case _ where button == buttons[3]: pressedButton = .number(4)
    case _ where button == buttons[4]: pressedButton = .number(5)
    case _ where button == buttons[5]: pressedButton = .number(6)
    case _ where button == buttons[6]: pressedButton = .number(7)
    case _ where button == buttons[7]: pressedButton = .number(8)
    case _ where button == buttons[8]: pressedButton = .number(9)
    case _ where button == buttons[9]: pressedButton = .number(0)
    case _ where button == leftButton: pressedButton = .left
    case _ where button == rightButton: pressedButton = .right
    default: pressedButton = .undefined
    }

    delegate?.numberPadButtonWasPressed(button: pressedButton)
  }
  
  func setupAppearance(with color: UIColor) {
    for button in buttons {
      button.setTitleColor(color, for: .normal)
    }
    
    rightButton.tintColor = color
  }
  
  func rightButtonEnable(_ isEnabled: Bool) {
    if isEnabled {
      rightButton.alpha = 1
    } else {
      rightButton.alpha = 0
    }
    
    rightButton.isEnabled = isEnabled
  }
}
