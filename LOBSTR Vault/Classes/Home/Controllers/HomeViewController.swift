import UIKit

class HomeViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .home
  
  @IBOutlet weak var transactionNumberLabel: UILabel!
  @IBOutlet weak var transactionsToSignLabel: UILabel!
  @IBOutlet weak var titleOfPublicKeyLabel: UILabel!
  @IBOutlet weak var titleOfsignerForLabel: UILabel!
  @IBOutlet weak var publicKeyLabel: UILabel!
  
  @IBOutlet weak var infoContainerView: UIView!
  @IBOutlet weak var signerDetailsView: UIView!
  
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
    
    signerDetailsProgressHUD.display(onView: signerDetailsView)
    transactionNumberProgressHUD.display(onView: transactionNumberLabel)
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - IBActions
  
  @IBAction func copyKeyButtonAction(_ sender: Any) {
    presenter.copyKeyButtonWasPressed()
  }
  
  @IBAction func transactionListButtonAction(_ sender: Any) {
    self.tabBarController?.selectedIndex = 2
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    AppearanceHelper.set(transactionListButton, with: L10n.buttonTitleViewTransactionsList)
    AppearanceHelper.set(copyKeyButton, with: L10n.buttonTitleCopyKey)
    setShadowAndCornersForInfoContainerView()
    
    publicKeyLabel.setLineHeight(lineHeight: 15)
    publicKeyLabel.textAlignment = .center
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
}

// MARK: - HomeView

extension HomeViewController: HomeView {
  
  func setSignerDetails(_ signedAccounts: [SignedAccounts]) {
    
    if signedAccounts.count == 1 {
      guard let address = signedAccounts.first?.address else { return }
      HomeHelper().createSignerDetailsViewForSingleAddress(in: signerDetailsView, address: address, bottomAnchor: titleOfsignerForLabel.bottomAnchor)
    } else {
      HomeHelper().createSignerDetailsViewForMultipleAddresses(in: signerDetailsView, for: String(signedAccounts.count), bottomAnchor: titleOfsignerForLabel.bottomAnchor)
    }
    
    signerDetailsProgressHUD.remove()
  }
  
  func setPublicKey(_ publicKey: String) {
    publicKeyLabel.text = publicKey
  }
  
  func setTransactionNumber(_ number: Int) {
    transactionNumberLabel.text = String(number)
    transactionNumberProgressHUD.remove()
  }
}
