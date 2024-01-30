import Lottie
import PKHUD
import UIKit

class TransactionStatusViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .transactions

  @IBOutlet var XDRContainerView: UIView!
  @IBOutlet var statusLabel: UILabel!
  @IBOutlet var doneButton: UIButton!
  @IBOutlet var xdrLabel: UILabel!
  @IBOutlet var descriptionMessageLabel: UILabel!
  @IBOutlet var signedXDRTitleLabel: UILabel!
  @IBOutlet var animationContainer: UIView!
  @IBOutlet var viewDetailsButton: UIButton!
  @IBOutlet var viewDetailsButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet var descriptionMessageLabelBottomConstraint: NSLayoutConstraint!
  
  var presenter: TransactionStatusPresenter!
  let feedbackGenerator = UINotificationFeedbackGenerator()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter.transactionStatusViewDidLoad()
    setupNavigationBar()
    setAppearance()
    setStaticString()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = true
    navigationController?.setStatusBar(backgroundColor: .white)
    navigationController?.setNavigationBarAppearance(backgroundColor: .white)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarAppearanceWithoutSeparatorForStandardAppearance()
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
  
  @IBAction func viewDetailsButtonAction(_ sender: Any) {
    presenter.viewDetailsButtonWasPressed()
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
  
  private func setupNavigationBar() {
    let moreIcon = Asset.Icons.Other.icMore.image
    let moreButton = UIBarButtonItem(image: moreIcon, style: .plain, target: self, action: #selector(moreDetailsButtonWasPressed))
  
    navigationItem.setRightBarButton(moreButton, animated: false)
  }
  
  @objc func moreDetailsButtonWasPressed() {
    let moreMenu = UIAlertController(title: nil,
                                     message: nil,
                                     preferredStyle: .actionSheet)
    
    let copySignedXdrAction = UIAlertAction(title: L10n.buttonTitleCopySignedXdr,
                                            style: .default) { _ in
      self.presenter.copySignedXdrButtonWasPressed()
    }
    
    let openHelpCenterAction = UIAlertAction(title: L10n.buttonTitleOpenHelpCenter,
                                             style: .default) { _ in
      self.presenter.helpButtonWasPressed()
    }
    
    let viewTransactionDetailsAction = UIAlertAction(title: L10n.buttonTitleViewTransactionDetails, style: .default) { _ in
      self.presenter.viewTransactionDetailsButtonWasPressed()
    }
    
    let cancelAction = UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel)
          
    moreMenu.addAction(openHelpCenterAction)
    moreMenu.addAction(viewTransactionDetailsAction)
    moreMenu.addAction(copySignedXdrAction)
    moreMenu.addAction(cancelAction)
      
    if let popoverPresentationController = moreMenu.popoverPresentationController {
      popoverPresentationController.sourceView = self.view
      popoverPresentationController.sourceRect = CGRect(x: view.bounds.midX,
                                                        y: view.bounds.midY,
                                                        width: 0,
                                                        height: 0)
      popoverPresentationController.permittedArrowDirections = []
    }
    present(moreMenu, animated: true, completion: nil)
  }
}

// MARK: - TransactionStatusView

extension TransactionStatusViewController: TransactionStatusView {
  func setStatusTitle(_ title: String) {
    statusLabel.text = title
  }
  
  func setAnimation(with status: TransactionStatus) {
    let transactionStatus: TransactionStatus = status == .failure ? .failure : .success
    let animationView = LOTAnimationView(name: transactionStatus.rawValue)
    
    animationContainer.addSubview(animationView)
    
    animationView.translatesAutoresizingMaskIntoConstraints = false
    animationView.centerXAnchor.constraint(equalTo: animationContainer.centerXAnchor).isActive = true
    animationView.centerYAnchor.constraint(equalTo: animationContainer.centerYAnchor).isActive = true
    
    animationView.play()
  }
  
  func setFeedback(with status: TransactionStatus) {
    status == .failure ?
      feedbackGenerator.notificationOccurred(.error) :
      feedbackGenerator.notificationOccurred(.success)
  }
  
  func setXdr(_ xdr: String) {
    XDRContainerView.isHidden = false
    xdrLabel.text = xdr
  }
  
  func setDescriptionMessage(_ message: String, transactionStatus: TransactionStatus) {
    descriptionMessageLabel.textColor = transactionStatus == .success ? Asset.Colors.grayOpacity70.color : Asset.Colors.red.color
    descriptionMessageLabel.text = message
  }
  
  func copy(_ xdr: String) {
    let pasteboard = UIPasteboard.general
    pasteboard.string = xdr
    HUD.flash(.labeledSuccess(title: nil,
                              subtitle: L10n.animationCopy), delay: 1.0)
  }
  
  func setViewDetailsButton(isHidden: Bool, title: String) {
    viewDetailsButton.isHidden = isHidden
    viewDetailsButton.setTitle(title, for: .normal)
    if isHidden {
      viewDetailsButtonBottomConstraint.isActive = false
      descriptionMessageLabelBottomConstraint.isActive = false
      descriptionMessageLabel.bottomAnchor.constraint(equalTo: XDRContainerView.topAnchor, constant: 10).isActive = true
    }
  }
  
  func showOperationMessageErrorDescriptionAlert(_ error: String) {
    let alert = UIAlertController(title: L10n.titleErrorOperationDetails, message: error, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleClose, style: .cancel))
    present(alert, animated: true, completion: nil)
  }
}
