import UIKit

enum LoginType {
  case tangem
  case standart
}

class AuthViewController: UIViewController, StoryboardCreation {

  static var storyboardType: Storyboards = .tangem
  
  @IBOutlet var publicKeyLabel: UILabel?
  @IBOutlet weak var signInButton: UIButton!
  
  var walletPublicKey: Data?
  var cardId: String?
  
  var publicKey: String?
  var loginType = LoginType.standart
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    AppearanceHelper.set(signInButton, with: "Sign In with Signer Card")
    
    switch loginType {
    case .standart:
      let vaultStorage = VaultStorage()
      guard let pk = vaultStorage.getPublicKeyFromKeychain() else { return }
      publicKey = pk
    case .tangem:
      guard let pk = try? walletPublicKey?.encodeEd25519PublicKey() else { return }
      publicKey = pk
//      VaultStorage().storePublicKeyInKeychain(pk)
      UserDefaultsHelper.tangemPublicKeyData = walletPublicKey
    }
        
    publicKeyLabel?.text = publicKey?.getTruncatedPublicKey()
  }

  @IBAction func authButtonAction(_ sender: Any) {
    switch loginType {
    case .standart:
      AuthenticationService().updateToken { [weak self] result in
        switch result {
        case .success:
          UserDefaultsHelper.accountStatus = .createdByDefault
          self?.transitionToHomeScreen()
        case .failure(let error):
          Logger.auth.error("Couldn't update token with error \(error)")
        }
      }
    case .tangem:
      AuthenticationService().updateTokenWithTangem(publicKey: publicKey!, walletPublicKey: walletPublicKey!, cardId: cardId!) { result in
        switch result {
        case .success:
          VaultStorage().storePublicKeyInKeychain(self.publicKey!)
          UserDefaultsHelper.accountStatus = .createdWithTangem
          self.transitionToHomeScreen()
        case .failure(let error):
          Logger.auth.error("Couldn't update token with error \(error)")
        }
      }
    }
  }
  
  func transitionToHomeScreen() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
    else { return }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      appDelegate.applicationCoordinator.showHomeScreen()
    }
  }
}
