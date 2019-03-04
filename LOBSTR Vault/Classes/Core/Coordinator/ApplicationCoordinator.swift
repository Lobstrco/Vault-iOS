import UIKit

class ApplicationCoordinator {
  private let window: UIWindow?
  
  let notificationRegistrator = NotificationManager()
  let accountStatus: AccountStatus
  
  init(window: UIWindow?) {
    self.window = window
    accountStatus = UserDefaultsHelper.accountStatus
  }
  
  func start() {    
    if UserDefaultsHelper.isNotificationsEnabled {
      notificationRegistrator.register()
    }
    
    openStartScreen()
  }
  
  func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {
    notificationRegistrator.setAPNSToken(deviceToken: deviceToken)
  }
  
  func sendFCMTokenToServer() {
    notificationRegistrator.sendFCMTokenToServer()
  }
  
  func postNotification(accordingTo userInfo: [AnyHashable : Any]) {
    notificationRegistrator.postNotification(accordingTo: userInfo)
  }
  
  private func openStartScreen() {
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
