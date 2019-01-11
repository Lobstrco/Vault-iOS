import UIKit

class MnemonicMenuViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .mnemonicMenu
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - IBAction
  
  @IBAction func createNewWalletWasPressed(_ sender: Any) {
    transitionToMnemonicGenerationScreen()
  }
  
  @IBAction func RestoreWalletWasPressed(_ sender: Any) {
    transitionToMnemonicRecoveryScreen()
  }
  
  // MARK: - Public Methods
  
  func transitionToMnemonicGenerationScreen() {
    let mnemonicGenerationViewController = MnemonicGenerationViewController.createFromStoryboard()
    navigationController?.pushViewController(mnemonicGenerationViewController, animated: true)
  }
  
  func transitionToMnemonicRecoveryScreen() {
    let mnemonicRecoveryViewController = MnemonicRecoveryViewController.createFromStoryboard()
    navigationController?.pushViewController(mnemonicRecoveryViewController, animated: true)
  }
}
