import UIKit
import PKHUD

class HomeViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .home
  
  @IBOutlet weak var transactionNumberLabel: UILabel!
  @IBOutlet weak var transactionsToSignLabel: UILabel!
  @IBOutlet weak var titleOfPublicKeyLabel: UILabel!
  @IBOutlet weak var titleOfsignerForLabel: UILabel!
  @IBOutlet weak var publicKeyLabel: UILabel!
  
  @IBOutlet weak var infoContainerView: UIView!
  @IBOutlet weak var signerDetailsView: UIView!
  @IBOutlet weak var transactionNumberView: UIView!
  
  @IBOutlet weak var transactionListButton: UIButton!
  @IBOutlet weak var copyKeyButton: UIButton!
  
  var presenter: HomePresenter!
  
  let signerDetailsProgressHUD = ProgressHUD()
  let transactionNumberProgressHUD = ProgressHUD(isWhite: true)
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
   
    presenter = HomePresenterImpl(view: self)
    presenter.homeViewDidLoad()
    
    setAppearance()
    setStaticStrings()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    presenter.updateSignerDetails()
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - IBActions
  
  @IBAction func copyKeyButtonAction(_ sender: Any) {
    presenter.copyKeyButtonWasPressed()
  }
  
  @IBAction func transactionListButtonAction(_ sender: Any) {
    self.tabBarController?.selectedIndex = 1
  }  
  
  // MARK: - Private
  
  private func setAppearance() {
    AppearanceHelper.set(transactionListButton, with: L10n.buttonTitleViewTransactionsList)
    AppearanceHelper.set(copyKeyButton, with: L10n.buttonTitleCopyKey)
    setShadowAndCornersForInfoContainerView()
  }
  
  private func setStaticStrings() {
    transactionsToSignLabel.text = L10n.textTransactionsToSign
    titleOfPublicKeyLabel.text = L10n.textVaultPublicKey
    titleOfsignerForLabel.text = L10n.textSignerFor
  }
  
  private func setShadowAndCornersForInfoContainerView() {
    let containerViewMargin: CGFloat = 16 + 16
    let borderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - containerViewMargin, height: infoContainerView.bounds.height))
    borderView.backgroundColor = Asset.Colors.white.color
    borderView.clipsToBounds = true
    borderView.layer.cornerRadius = 8
    
    infoContainerView.layer.shadowColor = UIColor.black.cgColor
    infoContainerView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
    infoContainerView.layer.shadowOpacity = 0.2
    infoContainerView.layer.shadowRadius = 4.0
    
    infoContainerView.addSubview(borderView)
    infoContainerView.sendSubviewToBack(borderView)
  }
  
  private func clear(_ subviews: [UIView]) {
    for view in subviews {
      view.removeFromSuperview()
    }
  }
}

// MARK: - HomeView

extension HomeViewController: HomeView {
  
  func setSignerDetails(_ signedAccounts: [SignedAccounts]) {
    
    if signedAccounts.count == 1 {
      guard let address = signedAccounts.first?.address else { return }
      let copyButton = HomeHelper.createSignerDetailsViewForSingleAddress(in: signerDetailsView,
                                                                            address: address,
                                                                            bottomAnchor: titleOfsignerForLabel.bottomAnchor)
      copyButton.addTarget(self, action: #selector(copySignerKeyButtonAction), for: .touchUpInside)
    } else {
      HomeHelper.createSignerDetailsViewForMultipleAddresses(in: signerDetailsView, for: String(signedAccounts.count), bottomAnchor: titleOfsignerForLabel.bottomAnchor)
    }
  }
  
  @objc func copySignerKeyButtonAction(sender: UIButton!) {
    presenter.copySignerKeyButtonWasPressed()
  }
  
  func setPublicKey(_ publicKey: String) {
    publicKeyLabel.text = publicKey
  }
  
  func setTransactionNumber(_ number: Int) {
    transactionNumberLabel.text = String(number)
  }
  
  func setTransactionNumber(_ number: String) {
    transactionNumberLabel.text = number
  }
  
  func setProgressAnimationForTransactionNumber(isEnabled: Bool) {
    DispatchQueue.main.async {
      if isEnabled {
        self.transactionNumberLabel.isHidden = true
        self.transactionNumberProgressHUD.display(onView: self.transactionNumberView)
      } else {
        self.transactionNumberProgressHUD.remove()
        self.transactionNumberLabel.isHidden = false
      }
    }
  }
  
  func setProgressAnimationForSignerDetails(isEnabled: Bool) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      isEnabled ? self.signerDetailsProgressHUD.display(onView: self.signerDetailsView) : self.signerDetailsProgressHUD.remove()
      if isEnabled {
        self.clear(self.signerDetailsView.subviews)
      }
    }
  }
  
  func setCopyHUD() {
    PKHUD.sharedHUD.contentView = PKHUDSuccessViewCustom(title: nil, subtitle: L10n.animationCopy)
    PKHUD.sharedHUD.show()
    PKHUD.sharedHUD.hide(afterDelay: 1.0)
  }
}
