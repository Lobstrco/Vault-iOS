import Foundation
import UIKit

protocol StartMenuPresenter {
  
  func startMenuViewDidLoad()
  func checkAppVersion()
  func createNewAccountButtonWasPressed()
  func restoreAccountButtonWasPressed()
  func signInWithCardButtonWasPressed()
  func termsButtonWasPressed()
  func privacyButtonWasPressed()
  func helpButtonWasPressed()
}

protocol StartMenuView: AnyObject {
  func setTermsButton()
  func open(by url: URL)
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
  
  func transitionToSignInWithSignerCard() {
    let tangemStartViewController = TangemStartViewController.createFromStoryboard()
    
    let startMenuViewController = view as! StartMenuViewController
    startMenuViewController.navigationController!.pushViewController(tangemStartViewController,
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
  
  func signInWithCardButtonWasPressed() {
    transitionToSignInWithSignerCard()
  }
  
  func termsButtonWasPressed() {
    let termsUrlString = "https://lobstr.co/terms/"
    guard let termsURL = URL(string: termsUrlString) else { return }
    
    view?.open(by: termsURL)
  }
  
  func privacyButtonWasPressed() {
    let privacyPolicyUrlString = "https://lobstr.co/privacy/"
    guard let privacyPolicyURL = URL(string: privacyPolicyUrlString) else { return }
    
    view?.open(by: privacyPolicyURL)
  }
  
  func helpButtonWasPressed() {
    let startMenuViewController = view as! StartMenuViewController
    let helpViewController = FreshDeskHelper.getHelpCenterController()
    startMenuViewController.navigationController?.present(helpViewController, animated: true)
  }
  
  func checkAppVersion() {
    if VersionControlHelper.checkIfAlertViewHasPresented() == nil {
      VersionControlHelper.checkAppVersion(showAlertImmediately: false) { versions in
        let compare = versions["min_app_version"]?.compare(VersionControlHelper.currentAppVersion, options: .numeric)
        if compare == .orderedDescending {
          VersionControlHelper.showForceUpdate()
        }
      }
    }
  }
}
