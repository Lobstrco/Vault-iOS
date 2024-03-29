import UIKit
import UserNotifications
import FirebaseMessaging
import TangemSdk

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
    
    if #available(iOS 13.0, *) {
      Localization.localizationsBundle = Bundle(for: AppDelegate.self)
    }
    
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
    window?.rootViewController = navigationController
  }
  
  func showPinScreen(mode: PinMode) {
    let pinViewController = PinEnterViewController.createFromStoryboard()
    pinViewController.mode = mode
    window?.rootViewController = pinViewController
  }
  
  func showAppropriateScreen(accordingTo userInfo: [AnyHashable: Any]) {
    guard let eventType = userInfo["event_type"] as? String, let notificationType = NotificationType(rawValue: eventType) else { return }
    
    switch notificationType {
    case .addedNewTransaction, .addedNewSignature:
      if let transactionString = userInfo["transaction"] as? String, let userAccountString = userInfo["user_account"] as? String {
        let transactionData = Data(transactionString.utf8)
        let userAccountData = Data(userAccountString.utf8)
        do {
          let transaction = try JSONDecoder().decode(Transaction.self, from: transactionData)
          let userAccount = try JSONDecoder().decode(UserAccountFromPush.self, from: userAccountData)
          // Multiaccount support case
          if let publicKeysFromKeychain = VaultStorage().getPublicKeysFromKeychain() {
            if let index = publicKeysFromKeychain.firstIndex(of: userAccount.address) {
              UserDefaultsHelper.activePublicKeyIndex = index
              UserDefaultsHelper.activePublicKey = userAccount.address
              ActivePublicKeyHelper.storeInKeychain(UserDefaultsHelper.activePublicKey)
              NotificationCenter.default.post(name: .didActivePublicKeyChange, object: nil)
              showTransactionsDetails(by: transaction)
            }
          } else {
            UserDefaultsHelper.activePublicKeyIndex = 0
            UserDefaultsHelper.activePublicKey = userAccount.address
            ActivePublicKeyHelper.storeInKeychain(UserDefaultsHelper.activePublicKey)
            showTransactionsDetails(by: transaction)
          }
        } catch {
          Logger.notifications.error("Failed to receive transaction")
        }
      }
    default:
      break
    }
  }
}

// MARK: - Private

private extension ApplicationCoordinator {
  
  func openStartScreen() {
    if accountStatus != .createdWithTangem {
      guard let _ = VaultStorage().getEncryptedMnemonicFromKeychain() else {
        ApplicationCoordinatorHelper.logout()
        return
      }
    } else {
      guard let _ = UserDefaultsHelper.tangemPublicKeyData,
            let _ = UserDefaultsHelper.tangemCardId,
            let _ = VaultStorage().getPublicKeyFromKeychain()
        else {
        ApplicationCoordinatorHelper.logout()
        return
      }
    }
        
    switch accountStatus {
    case .notCreated:
      Logger.auth.debug("AUTH. NOT CREATED")
      enablePromtForTransactionDecisions()
      ApplicationCoordinatorHelper.clearKeychain()
      showMenuScreen()
    case .createdWithTangem:
      // for previous version 1.3.2 without tangem support
      guard let _ = VaultStorage().getEncryptedMnemonicFromKeychain() else {
        Logger.auth.debug("AUTH. TANGEM")
        showHomeScreen()
        return
      }
      Logger.auth.debug("AUTH. WAITING TO SIGNER")
      enablePromtForTransactionDecisions()
      ApplicationCoordinatorHelper.clearKeychain()
      CloudKitNicknameHelper.getAllRecords()
      showMenuScreen()
    case .createdByDefault:
      Logger.auth.debug("AUTH. DEFAULT")
      CloudKitNicknameHelper.getAllRecords()
      showHomeScreen()
    }
  }
   
  func enablePromtForTransactionDecisions() {
     UserDefaultsHelper.isPromtTransactionDecisionsEnabled = true
  }
  
  func resetNotificationBadgeIfNeeded() {
    if accountStatus == .notCreated {
      notificationManager.setNotificationBadge(badgeNumber: 0)
    }
  }
  
  func showTransactionsDetails(by transaction: Transaction) {
    let transactionDetailsViewController = TransactionDetailsViewController.createFromStoryboard()
    transactionDetailsViewController.isAfterPushNotification = true
    
    transactionDetailsViewController.presenter =
      TransactionDetailsPresenterImpl(view: transactionDetailsViewController,
                                      transaction: transaction,
                                      type: .standard,
                                      isAfterPushNotification: true)
    Logger.transactionDetails.debug("Transaction: \(transaction)")
    transactionDetailsViewController.presenter.transactionListIndex = 0
    guard let tabBarViewController = self.window!.rootViewController as? TabBarViewController else { return }
    let navigationController = tabBarViewController.selectedViewController as? UINavigationController
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      navigationController?.pushViewController(transactionDetailsViewController, animated: true)
    }
  }
}

struct UserAccountFromPush: Codable {
  let address: String
}
