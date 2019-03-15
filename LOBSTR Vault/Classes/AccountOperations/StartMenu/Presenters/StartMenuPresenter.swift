import Foundation

protocol StartMenuPresenter {
  
  func startMenuViewDidLoad()
  func createNewAccountButtonWasPressed()
  func restoreAccountButtonWasPressed()
  func termsButtonWasPressed()
  func helpButtonWasPressed()
}

protocol StartMenuView: class {
  func setTermsButton()
  func openPrivacyPolicy(by url: URL)
}

class StartMenuPresenterImpl {
  
  fileprivate weak var view: StartMenuView?
  
  // MARK: - Init
  
  init(view: StartMenuView) {
    self.view = view
  }
  
  // MARK: - Public
  
  func transitionToMnemonicGenerationScreen() {
    let backUpAccountViewController = BackUpAccountViewController.createFromStoryboard()
    
    let mnemonicMenuViewController = view as! StartMenuViewController
    mnemonicMenuViewController.navigationController?.pushViewController(backUpAccountViewController,
                                             animated: true)
  }
  
  func transitionToMnemonicRecoveryScreen() {
    let mnemonicRecoveryViewController = MnemonicRecoveryViewController.createFromStoryboard()
    
    let startMenuViewController = view as! StartMenuViewController
    startMenuViewController.navigationController!.pushViewController(mnemonicRecoveryViewController,
                                             animated: true)
  }
}

// MARK: - StartMenuPresenter

extension StartMenuPresenterImpl: StartMenuPresenter {
  
  func startMenuViewDidLoad() {
    view?.setTermsButton()    
  }
  
  func createNewAccountButtonWasPressed() {
    transitionToMnemonicGenerationScreen()
  }
  
  func restoreAccountButtonWasPressed() {
    transitionToMnemonicRecoveryScreen()
  }
  
  func termsButtonWasPressed() {
    let privacyPolicyUrlString = "https://lobstr.co/privacy/"
    guard let privacyPolicyURL = URL(string: privacyPolicyUrlString)
      else { return }
    
    view?.openPrivacyPolicy(by: privacyPolicyURL)    
  }
  
  func helpButtonWasPressed() {
    let helpViewController = HelpViewController.createFromStoryboard()
    
    let startMenuViewController = view as! StartMenuViewController
    startMenuViewController.navigationController?.pushViewController(helpViewController, animated: true)
  }
}
