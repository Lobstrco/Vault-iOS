import UIKit
import TangemSdk

@available(iOS 13.0, *)
class TangemCreateWalletViewController: UIViewController, StoryboardCreation {

  static var storyboardType: Storyboards = .tangem
  
  @IBOutlet weak var createButton: UIButton!
  
  var curve: EllipticCurve?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    AppearanceHelper.set(createButton, with: "Create Signer Account")
  }

  @IBAction func createWalletButtonAction(_ sender: Any) {
    createWallet()
  }
  
  @IBAction func helpButtonAction(_ sender: Any) {
    let helpViewController = FreshDeskHelper.getFreshDeskArticleController(article: .signingTangem)
    navigationController?.present(helpViewController, animated: true)
  }
  
  func createWallet() {
    guard let cardId = UserDefaultsHelper.tangemCardId else { return }
    TangemHelper.createWallet(cardId: cardId, curve: curve) { result in
      switch result {
      case .success(let createWalletResponse):
        UserDefaultsHelper.tangemCardId = createWalletResponse.cardId
        self.transactionToAuth(walletPublicKey: createWalletResponse.wallet.publicKey, cardId: createWalletResponse.cardId)
      case .failure(let error):
        Logger.tangem.error(error)
      }
    }
  }  
  
  func transactionToAuth(walletPublicKey: Data, cardId: String) {
    let authViewController = AuthViewController.createFromStoryboard()
    authViewController.cardId = cardId
    authViewController.walletPublicKey = walletPublicKey
    authViewController.loginType = .tangem
    navigationController!.pushViewController(authViewController, animated: true)
  }

}
