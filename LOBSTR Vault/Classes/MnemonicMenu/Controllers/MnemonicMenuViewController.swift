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
    guard let vc = MnemonicGenerationViewController.createFromStoryboard() else { fatalError() }
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func transitionToMnemonicRecoveryScreen() {
    guard let vc = MnemonicRecoveryViewController.createFromStoryboard() else { fatalError() }
    navigationController?.pushViewController(vc, animated: true)
  }
}