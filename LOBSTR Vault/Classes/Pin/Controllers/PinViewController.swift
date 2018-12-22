import UIKit

protocol PinView: class {
  func showTitle(_ title: String)
  func fillPinDot(at index: Int)
  func clearPinDot(at index: Int)
  func shakePinView()
}

class PinViewController: UIViewController, PinView, NumberPadViewDelegate,
  StoryboardCreation {
  static var storyboardType: Storyboards = .pin
  
  var mode: PinMode = .undefined
  
  @IBOutlet var pinView: PinInputView!
  @IBOutlet var numberPadView: NumberPadView!
  
  let impact = UIImpactFeedbackGenerator(style: .light)
  var presenter: PinPresenter!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter = PinPresenterImpl(view: self,
                                 navigationController: navigationController!,
                                 mode: mode)
    pinView.clearPinDots()
    numberPadView.delegate = self
    
    presenter.pinViewDidLoad()
  }
  
  // MARK: - PinView
  
  func showTitle(_ title: String) {
    self.title = title
  }
  
  func fillPinDot(at index: Int) {
    pinView.fillPinDot(at: index)
  }
  
  func clearPinDot(at index: Int) {
    pinView.clearPinDot(at: index)
  }
  
  func shakePinView() {
    pinView.shake()
  }
  
  // MARK: - NumberPadViewDelegate
  
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

