import UIKit

protocol PinView: class {
  func setTitle(_ title: String)
  func setCancelBarButtonItem()
  func fillPinDot(at index: Int)
  func clearPinDot(at index: Int)
  func clearPinDots()
  func shakePinView()
  func setNavigationItem()
  func hideBackButton()
  func show(error: String)
  func executeCompletion()
}

class PinViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .pin
  
  var mode: PinMode = .undefined
  
  @IBOutlet var numberPadView: NumberPadView!
  @IBOutlet var pinDotView: PinDotView!
  @IBOutlet var errorLabel: UILabel!
  
  let impact = UIImpactFeedbackGenerator(style: .light)
  var presenter: PinPresenter!
  
  var completion: (() -> Void)?
  
  lazy var cancelBarButtonItem: UIBarButtonItem = {
    let selector = #selector(canceBarButtonItemAction)
    let item = UIBarButtonItem(barButtonSystemItem: .cancel,
                               target: self, action: selector)
    return item
  }()
  
  
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    presenter.pinViewWillAppear()
  }
  
  @IBAction func helpButtonAction(_ sender: Any) {    
    presenter.helpButtonWasPressed()
  }
  
  @objc func canceBarButtonItemAction() {
    dismiss(animated: true, completion: nil)
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
  
  func setCancelBarButtonItem() {
    navigationController?.navigationBar.tintColor = Asset.Colors.main.color
    navigationItem.leftBarButtonItem = cancelBarButtonItem
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
  
  func show(error: String) {
    errorLabel.text = error
  }
  
  func executeCompletion() {
    completion?()
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
