import UIKit

class HomeViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .home
  
  @IBOutlet weak var transactionNumberLabel: UILabel!
  @IBOutlet weak var transactionsToSignLabel: UILabel!
  @IBOutlet weak var titleOfPublicKeyLabel: UILabel!
  @IBOutlet weak var titleOfsignerForLabel: UILabel!
  @IBOutlet weak var signerForLabel: UILabel!
  @IBOutlet weak var publicKeyLabel: UILabel!
  
  @IBOutlet weak var infoContainerView: UIView!
  
  @IBOutlet weak var transactionListButton: UIButton!
  @IBOutlet weak var copyKeyButton: UIButton!
  
  var presenter: HomePresenter!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
   
    presenter = HomePresenterImpl(view: self)
    presenter.homeViewDidLoad()
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - Private
  
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
  
  func setDesignDetails() {
    setShadowAndCornersForInfoContainerView()
    
    copyKeyButton.layer.cornerRadius = 6
    transactionListButton.layer.cornerRadius = 6
    
    publicKeyLabel.setLineHeight(lineHeight: 15)
    publicKeyLabel.textAlignment = .center
    
    signerForLabel.setLineHeight(lineHeight: 15)
    signerForLabel.textAlignment = .center
  }
  
  func setPublicKey(_ publicKey: String) {
    
  }
  
  func setSignerDetails() {
    
  }
  
  func setTransactionNumber(_ number: Int) {
    transactionNumberLabel.text = String(number)
  }
  
  func setStaticStrings() {
    transactionsToSignLabel.text = L10n.textTransactionsToSign
    titleOfPublicKeyLabel.text = L10n.textVaultPublicKey
    titleOfsignerForLabel.text = L10n.textSignerFor
  }
  
  func setButtonTitles() {
    transactionListButton.setTitle(L10n.buttonTitleViewTransactionsList, for: .normal)
    copyKeyButton.setTitle(L10n.buttonTitleCopyKey, for: .normal)
  }
}
