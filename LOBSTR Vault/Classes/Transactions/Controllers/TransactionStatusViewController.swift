import UIKit
import Lottie
import PKHUD

class TransactionStatusViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .transactions

  @IBOutlet weak var XDRContainerView: UIView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var xdrLabel: UILabel!
  @IBOutlet weak var errorMessageLabel: UILabel!
  @IBOutlet weak var signedXDRTitleLabel: UILabel!
  @IBOutlet weak var animationContainer: UIView!
  
  var presenter: TransactionStatusPresenter!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter.transactionStatusViewDidLoad()
    
    setAppearance()
    setStaticString()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = true
  }
  
  // MARK: - IBActions
  
  @IBAction func closeButtonAction(_ sender: Any) {
    presenter.doneButtonWasPressed()
  }
  
  @IBAction func copyXDRAction(_ sender: Any) {
    guard let xdr = xdrLabel.text else {
      return
    }
    
    presenter.copyXDRButtonWasPressed(xdr: xdr)
    HUD.flash(.labeledSuccess(title: nil, subtitle: L10n.animationCopy), delay: 1.0)
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    AppearanceHelper.set(doneButton, with: L10n.buttonTitleDone)
    navigationItem.hidesBackButton = true    
    
    guard let xdrView = XDRContainerView.subviews.first else {
      return
    }
    
    xdrView.layer.cornerRadius = 5
    xdrView.layer.borderColor = Asset.Colors.grayOpacity70.color.cgColor
    xdrView.layer.borderWidth = 1
  }
  
  private func setStaticString() {
    signedXDRTitleLabel.text = L10n.textStatusSignedXdrTitle
  }
}

// MARK: - TransactionStatusView

extension TransactionStatusViewController: TransactionStatusView {
  
  func setStatusTitle(_ title: String) {
    statusLabel.text = title
  }
  
  func setAnimation(with status: TransactionStatus) {
    let animationView = LOTAnimationView(name: status.rawValue)
    
    animationContainer.addSubview(animationView)
    
    animationView.translatesAutoresizingMaskIntoConstraints = false
    animationView.centerXAnchor.constraint(equalTo: animationContainer.centerXAnchor).isActive = true
    animationView.centerYAnchor.constraint(equalTo: animationContainer.centerYAnchor).isActive = true
    
    animationView.play()
  }
  
  func setXdr(_ xdr: String) {
    XDRContainerView.isHidden = false
    xdrLabel.text = xdr
  }
  
  func setErrorMessage(_ message: String) {
    errorMessageLabel.text = message
  }
  
}
