import FirebaseMessaging
import Foundation
import UIKit
import UserNotifications

class NotificationManager {
  func requestAuthorization(completionHandler: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { granted, _ in
      completionHandler(granted)
    }
  }
  
  func register(allAccounts: Bool = true) {
    if allAccounts {
      UIApplication.shared.registerForRemoteNotifications()
    }
    sendFCMTokenToServer()
  }
  
  func unregister(allAccounts: Bool = true) {
    if allAccounts {
      UIApplication.shared.unregisterForRemoteNotifications()
    }
    
    guard let fcmToken = Messaging.messaging().fcmToken else {
      Logger.notifications.error("Failed to unregister device")
      return
    }
    
    NotificationsService().unregisterDeviceForNotifications(with: fcmToken)
  }
  
  func registerAllAccountsForRemoteNotifications() {
    guard let fcmToken = Messaging.messaging().fcmToken else {
      Logger.notifications.error("Failed to register device. Couldn't get fcm token")
      return
    }
    let vaultStorage = VaultStorage()
    if let jwtTokensInfo = vaultStorage.getJWTTokensFromKeychain() {
      for publicKey in jwtTokensInfo.keys {
        if let jwtToken = jwtTokensInfo[publicKey] {
          UserDefaultsHelper.pushNotificationsStatuses[publicKey] = true
          NotificationsService().registerDeviceForNotifications(with: fcmToken, with: jwtToken)
        }
      }
    }
  }
  
  func unregisterAllAccountsForRemoteNotifications() {
    guard let fcmToken = Messaging.messaging().fcmToken else {
      Logger.notifications.error("Failed to unregister device. Couldn't get fcm token")
      return
    }
    let vaultStorage = VaultStorage()
    if let jwtTokensInfo = vaultStorage.getJWTTokensFromKeychain() {
      let jwtTokens = jwtTokensInfo.values
      for jwtToken in jwtTokens {
        NotificationsService().unregisterDeviceForNotifications(with: fcmToken, with: jwtToken)
      }
    } else {
      NotificationsService().unregisterDeviceForNotifications(with: fcmToken)
    }
  }

  func setAPNSToken(deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
  
  func sendFCMTokenToServer() {
    guard let fcmToken = Messaging.messaging().fcmToken else {
      return
    }
    Logger.notifications.debug("FCM Token: \(fcmToken)")
    NotificationsService().registerDeviceForNotifications(with: fcmToken)
  }
  
  func setNotificationBadge(badgeNumber: Int) {
    UIApplication.shared.applicationIconBadgeNumber = badgeNumber
  }
  
  func setNotificationBadge(accordingTo userInfo: [AnyHashable: Any]) {
    guard let aps = userInfo["aps"] as? [AnyHashable: Any], let badge = aps["badge"] as? Int else {
      UIApplication.shared.applicationIconBadgeNumber = 0
      return
    }
    
    UIApplication.shared.applicationIconBadgeNumber = badge
  }
  
  func postNotification(accordingTo userInfo: [AnyHashable: Any]) {
    guard let eventType = userInfo["event_type"] as? String else {
      return
    }
    
    guard let notificationType = NotificationType(rawValue: eventType) else {
      return
    }
    
    switch notificationType {
      case .addedNewTransaction, .submitedTransaction, .addedNewSignature:
        NotificationCenter.default.post(name: .didChangeTransactionList, object: nil)
      case .signedNewAccount:
        NotificationCenter.default.post(name: .didChangeSignerDetails, object: nil)
      case .removedSigner:
        NotificationCenter.default.post(name: .didChangeSignerDetails, object: nil)
    }
  }
}

enum NotificationType: String {
  case addedNewTransaction = "added_new_transaction"
  case submitedTransaction = "transaction_submitted"
  case signedNewAccount = "signed_new_account"
  case removedSigner = "removed_signer"
  case addedNewSignature = "added_new_signature"
}
