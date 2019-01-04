import UIKit

class ApplicationCoordinator {
  private let window: UIWindow?
  private let mnemonicManager = MnemonicManagerImpl()
  private let pinManager = PinManagerImpl()
  
  init(window: UIWindow?) {
    self.window = window
  }
  
  func startUserFlow() {
    if mnemonicManager.isMnemonicStoredInKeychain() {
      
      if pinManager.isPinStoredInKeychain() {
        showPinScreen()
      } else {
        showHomeScreen()
      }
      
    } else {
      showMenuScreen()
    }
  }
  
  func showHomeScreen() {
    guard let tabBarViewController = TabBarViewController.createFromStoryboard() else { return }
    window?.rootViewController = tabBarViewController
  }
  
  func showMenuScreen() {
    guard let menuViewController = MnemonicMenuViewController.createFromStoryboard()
    else { return }
    let navigation = UINavigationController(rootViewController: menuViewController)
    window?.rootViewController = navigation
  }
  
  func showPinScreen() {
    guard let pinViewController = PinViewController.createFromStoryboard()
    else { return }
    
    pinViewController.mode = .enterPin
    
    let navigation = UINavigationController(rootViewController: pinViewController)
    window?.rootViewController = navigation
  }
}
