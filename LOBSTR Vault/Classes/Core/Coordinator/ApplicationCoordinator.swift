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
    let tabBarViewController = TabBarViewController.createFromStoryboard()
    window?.rootViewController = tabBarViewController
  }
  
  func showMenuScreen() {
    let menuViewController = MnemonicMenuViewController.createFromStoryboard()
    
    let navigation = UINavigationController(rootViewController: menuViewController)
    window?.rootViewController = navigation
  }
  
  func showPinScreen() {
    let pinViewController = PinViewController.createFromStoryboard()    
    
    pinViewController.mode = .enterPin
    
    let navigation = UINavigationController(rootViewController: pinViewController)
    window?.rootViewController = navigation
  }
}
