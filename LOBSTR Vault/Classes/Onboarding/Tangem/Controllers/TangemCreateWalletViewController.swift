import UIKit

class TangemCreateWalletViewController: UIViewController, StoryboardCreation {

  static var storyboardType: Storyboards = .tangem
  
  @IBOutlet weak var createButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    AppearanceHelper.set(createButton, with: "Create Signer Account")
  }

  @IBAction func createWalletButtonAction(_ sender: Any) {
    if #available(iOS 13.0, *) {
      createWallet()
    } else {
      Logger.tangem.error("Tangem SDK supports version higher 13")
    }
  }
  
  @IBAction func helpButtonAction(_ sender: Any) {
    let helpViewController = ZendeskHelper.getZendeskArticleController(article: .signingTangem)
    navigationController?.pushViewController(helpViewController, animated: true)
  }
  
  @available(iOS 13.0, *)
  func createWallet() {
    guard let cardId = UserDefaultsHelper.tangemCardId else { return }
    TangemHelper.createWallet(cardId: cardId) { result in
      switch result {
      case .success(let createWalletResponse):
        UserDefaultsHelper.tangemCardId = createWalletResponse.cardId
        self.transactionToAuth(walletPublicKey: createWalletResponse.walletPublicKey, cardId: createWalletResponse.cardId)
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
