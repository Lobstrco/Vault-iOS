import UIKit

class AuthenticationViewController: UIViewController, StoryboardCreation {

  static var storyboardType: Storyboards = .authentication
  
  @IBOutlet weak var scanButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    AppearanceHelper.set(scanButton, with: "Scan Signer Card")
  }

  @IBAction func scanCardButtonAction(_ sender: UIButton) {
    guard let walletPublicKey = UserDefaultsHelper.tangemPublicKeyData,
          let cardId = UserDefaultsHelper.tangemCardId,
          let publicKey = VaultStorage().getPublicKeyFromKeychain()
      else { return }
    
    AuthenticationService().updateTokenWithTangem(publicKey: publicKey, walletPublicKey: walletPublicKey, cardId: cardId) { result in
      switch result {
      case .success(_):
        NotificationCenter.default.post(name: .didJWTTokenUpdate, object: nil)
      case .failure(let error):
        Logger.auth.error("Couldn't update token for signer card with error: \(error)")
      }
      DispatchQueue.main.async {
        self.dismiss(animated: true, completion: nil)
      }
    }
  }
}
