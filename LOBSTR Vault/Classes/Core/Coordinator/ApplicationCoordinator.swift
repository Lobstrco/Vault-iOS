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
    
    resetNotificationBadgeIfNeeded()
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
  
  func setNotificationBadge(accordingTo userInfo: [AnyHashable : Any]) {    
    notificationManager.setNotificationBadge(accordingTo: userInfo)
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
  
  func showPinScreen(mode: PinMode) {
    let pinViewController = PinEnterViewController.createFromStoryboard()
    pinViewController.mode = mode
    window?.rootViewController = pinViewController
  }
  
  func showPublicKeyScreen() {
    let vaultPublicKeyViewController = VaultPublicKeyViewController.createFromStoryboard()
    let navigationController = UINavigationController(rootViewController: vaultPublicKeyViewController)
    AppearanceHelper.setNavigationApperance(navigationController)
    window?.rootViewController = navigationController
  }
}

// MARK: - Private

private extension ApplicationCoordinator {
  
  func openStartScreen() {
    switch accountStatus {
    case .notCreated:
      enablePromtForTransactionDecisions()
      ApplicationCoordinatorHelper.clearKeychain()
      showMenuScreen()
    case .waitingToBecomeSigner:
      enablePromtForTransactionDecisions()
      showPinScreen(mode: .enterPinForWaitingToBecomeSigner)
    case .created:
      showPinScreen(mode: .enterPin)
    }
  }
   
  func enablePromtForTransactionDecisions() {
     UserDefaultsHelper.isPromtTransactionDecisionsEnabled = true
  }
  
  func resetNotificationBadgeIfNeeded() {
    if accountStatus != .created {
      notificationManager.setNotificationBadge(badgeNumber: 0)
    }
  }
}
