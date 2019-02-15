import UIKit

class PinViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .pin
  
  var mode: PinMode = .undefined
  
  @IBOutlet var numberPadView: NumberPadView!
  @IBOutlet var pinDotView: PinDotView!
  
  let impact = UIImpactFeedbackGenerator(style: .light)
  var presenter: PinPresenter!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter = PinPresenterImpl(view: self, mode: mode)
    
    numberPadView.delegate = self
    
    presenter.pinViewDidLoad()
    pinDotView.clearPinDots()
    
    setAppearance()
    setStaticStrings()
  }
  
  @IBAction func helpButtonAction(_ sender: Any) {    
    presenter.helpButtonWasPressed()
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    pinDotView.setupAppearance(with: (fillColor: Asset.Colors.main.color, outColor: Asset.Colors.background.color))
    numberPadView.setupAppearance(with: Asset.Colors.black.color)
  }
  
  private func setStaticStrings() {
    
  }
}

// MARK: - PinView

extension PinViewController: PinView {
  
  func setTitle(_ title: String) {
    navigationItem.title = title
  }
  
  func fillPinDot(at index: Int) {
    pinDotView.fillPinDot(at: index)
  }
  
  func clearPinDot(at index: Int) {
    pinDotView.clearPinDot(at: index)
  }
  
  func clearPinDots() {
    pinDotView.clearPinDots()
  }
  
  func shakePinView() {
    pinDotView.shake()
  }
  
  func setNavigationItem() {
    navigationItem.largeTitleDisplayMode = .never
  }
  
  func hideBackButton() {
    navigationItem.hidesBackButton = true
  }
}

// MARK: - NumberPadViewDelegate

extension PinViewController: NumberPadViewDelegate {
  
  func numberPadButtonWasPressed(button: NumberPadButton) {
    
    impact.impactOccurred()
    
    switch button {
    case .number(let digit):
      presenter.digitButtonWasPressed(with: digit)
    case .right:
      presenter.removeButtonWasPressed()
    default:
      break
    }
  }
}
