import UIKit

import UserNotifications
import FirebaseMessaging

class ApplicationCoordinator {
  private let window: UIWindow?
  
  let notificationManager = NotificationManager()
  let accountStatus: AccountStatus
  
  init(window: UIWindow?) {
    self.window = window
    accountStatus = UserDefaultsHelper.accountStatus
  }
  
  func start(appDelegate: AppDelegate) {
    Messaging.messaging().delegate = appDelegate
    UNUserNotificationCenter.current().delegate = appDelegate

    if UserDefaultsHelper.isNotificationsEnabled {
      notificationManager.sendFCMTokenToServer()
    }
    
    openStartScreen()
  }
  
  func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {
    notificationManager.setAPNSToken(deviceToken: deviceToken)
  }
  
  func sendFCMTokenToServer() {
    notificationManager.sendFCMTokenToServer()
  }
  
  func postNotification(accordingTo userInfo: [AnyHashable : Any]) {
    notificationManager.postNotification(accordingTo: userInfo)
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
