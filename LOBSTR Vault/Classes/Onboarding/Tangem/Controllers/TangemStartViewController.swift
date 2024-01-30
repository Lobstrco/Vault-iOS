import TangemSdk
import UIKit

class TangemStartViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .tangem
  @IBOutlet var scanButton: UIButton!
  @IBOutlet var buyNowButton: UIButton!
    
  @IBOutlet var learnMoreButtonTopConstraint: NSLayoutConstraint!
  @IBOutlet var aboutLabelHeightConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    AppearanceHelper.set(scanButton, with: "Scan Signer Card")
    AppearanceHelper.set(buyNowButton, with: "Buy Now")
    
    buyNowButton.layer.borderColor = Asset.Colors.main.color.cgColor
    buyNowButton.layer.borderWidth = 1
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(false, animated: animated)
    navigationController?.setStatusBar(backgroundColor: Asset.Colors.pink.color)
    navigationController?.navigationBar.backgroundColor = Asset.Colors.pink.color
    navigationController?.navigationBar.barTintColor = Asset.Colors.pink.color
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.navigationBar.barTintColor = Asset.Colors.white.color
    navigationController?.navigationBar.backgroundColor = Asset.Colors.white.color
  }
    
  @IBAction func scanButtonAction(_ sender: Any) {
    scanCard()
  }
  
  @IBAction func learnMoreButtonAction(_ sender: Any) {
    UtilityHelper.openTangemVaultLanding()
  }
  
  @IBAction func buyNowButtonAction(_ sender: Any) {
    UtilityHelper.openTangemShop()
  }
  
  @IBAction func helpButtonAcion() {
    let helpViewController = FreshDeskHelper.getFreshDeskArticleController(article: .signingTangem)
    navigationController?.present(helpViewController, animated: true)
  }
  
  func setupUI() {
    switch UIDevice().type {
    case .iPhone5, .iPhone5C, .iPhone5S, .iPhoneSE:
      aboutLabelHeightConstraint.constant = 55
      learnMoreButtonTopConstraint.constant = 5
    default:
      learnMoreButtonTopConstraint.constant = 16
      aboutLabelHeightConstraint.constant = 72
    }
  }
  
  func scanCard() {
    guard #available(iOS 13.0, *) else {
      displayiOSSupportAlert()
      return
    }
    
    TangemHelper.scanCard { result in
      switch result {
      case .success(let card):
        UserDefaultsHelper.tangemCardId = card.cardId
                
        guard let wallet = card.wallets.first, let _ = try? wallet.publicKey.encodeEd25519PublicKey() else {
          self.transactionToWalletCreation(curve: card.supportedCurves.first)
          return
        }
                
        self.transactionToAuth(walletPublicKey: wallet.publicKey, cardId: card.cardId)
      case .failure(let error):
        switch error {
        case .unsupportedDevice:
          self.displayNFCDisabledAlert()
          Logger.tangem.error("This device is not supported by Tangem card")
        default:
          Logger.tangem.error("Couldn't scan tangem card with error: \(error)")
        }
      }
    }
  }
  
  func displayiOSSupportAlert() {
    let alert = UIAlertController(title: "iOS 12 or lower not supported",
                                  message: "Signer Card can’t be scanned. Signer card only works with iOS 13 or higher.",
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel))
    present(alert, animated: true, completion: nil)
  }
  
  func displayNFCDisabledAlert() {
    let alert = UIAlertController(title: "NFC not supported",
                                  message: "Signer Card can’t be scanned. This device does not support NFC functionality.",
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel))
    present(alert, animated: true, completion: nil)
  }

  @available(iOS 13.0, *)
  func transactionToWalletCreation(curve: EllipticCurve?) {
    let tangemCreateWalletViewController = TangemCreateWalletViewController.createFromStoryboard()
    tangemCreateWalletViewController.curve = curve
    navigationController!.pushViewController(tangemCreateWalletViewController, animated: true)
  }
  
  func transactionToAuth(walletPublicKey: Data?, cardId: String?) {
    let authViewController = AuthViewController.createFromStoryboard()
    authViewController.cardId = cardId
    authViewController.walletPublicKey = walletPublicKey
    authViewController.loginType = .tangem
    navigationController!.pushViewController(authViewController, animated: true)
  }
}
