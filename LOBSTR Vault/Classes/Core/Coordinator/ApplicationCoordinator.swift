import UIKit

class ApplicationCoordinator {
  private let window: UIWindow?
  
  init(window: UIWindow?) {
    self.window = window
  }
  
  func openRequiredScreen() {
    let accountStatus = ApplicationCoordinatorHelper.getAccountStatus()
    
    switch accountStatus {
    case .notCreated:
      ApplicationCoordinatorHelper.clearKeychain()
      showMenuScreen()
    case .waitingToBecomeSinger:
      showPublicKeyScreen()
    case .created:
      showPinScreen()
    }
  }
  
  func showHomeScreen() {
    let tabBarViewController = TabBarViewController.createFromStoryboard()
    window?.rootViewController = tabBarViewController
  }
  
  func showMenuScreen() {
    let startMenuViewController = StartMenuViewController.createFromStoryboard()
    let navigationController = UINavigationController(rootViewController: startMenuViewController)
    AppearanceHelper.setNavigationApperance(navigationController)
    window?.rootViewController = navigationController
  }  
  
  func showPinScreen() {
    let pinViewController = PinEnterViewController.createFromStoryboard()
    window?.rootViewController = pinViewController
  }
  
  func showPublicKeyScreen() {
    let publicKeyViewController = PublicKeyViewController.createFromStoryboard()
    let navigationController = UINavigationController(rootViewController: publicKeyViewController)
    AppearanceHelper.setNavigationApperance(navigationController)
    window?.rootViewController = navigationController
  }
}
