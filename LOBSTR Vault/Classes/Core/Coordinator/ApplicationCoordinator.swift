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
    let startMenuViewController = StartMenuViewController.createFromStoryboard()
    let navigationController = UINavigationController(rootViewController: startMenuViewController)
    setNavigationApperance(navigationController)
    window?.rootViewController = navigationController
  }  
  
  func showPinScreen() {
    let pinViewController = PinEnterViewController.createFromStoryboard()
    window?.rootViewController = pinViewController
  }
  
  private func setNavigationApperance(_ navigationController: UINavigationController) {
    navigationController.navigationBar.prefersLargeTitles = true
    navigationController.navigationBar.tintColor = Asset.Colors.main.color
    navigationController.navigationBar.barTintColor = Asset.Colors.white.color
    navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController.navigationBar.shadowImage = UIImage()
    navigationController.navigationBar.topItem?.title = ""
  }

}
