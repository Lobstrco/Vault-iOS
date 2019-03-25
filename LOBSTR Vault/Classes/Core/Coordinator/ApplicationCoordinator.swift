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
  
  private func openStartScreen() {
    switch accountStatus {
    case .notCreated:
      enablePromtForTransactionDecisions()
      ApplicationCoordinatorHelper.clearKeychain()
      showMenuScreen()
    case .waitingToBecomeSinger:
      enablePromtForTransactionDecisions()
      showPublicKeyScreen()
    case .created:
      showPinScreen()
    }
  }
  
  private func enablePromtForTransactionDecisions() {
    UserDefaultsHelper.isPromtTransactionDecisionsEnabled = true
  }
}
