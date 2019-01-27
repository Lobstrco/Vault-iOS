import UIKit
import Lottie

class TransactionStatusViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .transactions

  @IBOutlet weak var XDRContainerView: UIView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var xdrLabel: UILabel!
  
  @IBOutlet weak var statusDescriptionLabel: UILabel!
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
    tabBarController?.tabBar.isHidden = true
  }
  
  // MARK: - IBActions
  
  @IBAction func closeButtonAction(_ sender: Any) {
    presenter.doneButtonWasPressed()
  }
  
  @IBAction func copyXDRAction(_ sender: Any) {
//    presenter.copyXDRButtonWasPressed(xdr: xdrLabel.text)
  }
  
  // MARK: - Private
  private func setAppearance() {
    AppearanceHelper.set(navigationController)
    
    AppearanceHelper.set(doneButton, with: L10n.buttonTitleDone)
    XDRContainerView.layer.cornerRadius = 5
    XDRContainerView.layer.borderColor = Asset.Colors.grayOpacity70.color.cgColor
    XDRContainerView.layer.borderWidth = 1
    
    navigationItem.hidesBackButton = true
  }
  
  private func setStaticString() {
    statusDescriptionLabel.text = L10n.textStatusDescription
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
  
  
}
