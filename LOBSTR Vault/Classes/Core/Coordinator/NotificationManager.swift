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
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
  }
  
  func setNotificationBadge(accordingTo userInfo: [AnyHashable: Any]) {
    guard let eventType = userInfo["event_type"] as? String,
          let notificationType = NotificationType(rawValue: eventType) else { return }
        
    switch notificationType {
      case .removedSigner:
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
          if let removedAccount = self.getRemovedAccount(notifications: notifications) {
            let newRemovedSignerPushId = notifications.first?.request.identifier
            var notificationsForDelete: [UNNotification] = []
  
            for notification in notifications {
              guard let eventType = notification.request.content.userInfo["event_type"] as? String,
                    let notificationType = NotificationType(rawValue: eventType) else { return }
              
              switch notificationType {
                case .addedNewTransaction, .addedNewSignature, .submitedTransaction:
                  self.checkIfNotificationWithTransactionForDelete(notification: notification, removedAccount: removedAccount, notificationsForDelete: &notificationsForDelete)
                case .removedSigner, .signedNewAccount:
                  self.checkIfNotificationForDelete(notification: notification, removedAccount: removedAccount, notificationsForDelete: &notificationsForDelete)
              }
            }
            
            var allIdentifiersForDelete: [String] = []
            for notificationForDelete in notificationsForDelete {
              allIdentifiersForDelete.append(notificationForDelete.request.identifier)
            }
            let identifiersForDelete = allIdentifiersForDelete.filter { $0 != newRemovedSignerPushId }
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiersForDelete)
          }
        }
      
      default:
        guard let aps = userInfo["aps"] as? [AnyHashable: Any], let badge = aps["badge"] as? Int else {
          UIApplication.shared.applicationIconBadgeNumber = -1
          return
        }
      
        UIApplication.shared.applicationIconBadgeNumber = badge
    }
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

extension NotificationManager {
  private func getRemovedAccount(notifications: [UNNotification]) -> UserAccountFromPush? {
    var removedAccount: UserAccountFromPush?
    if let removedSignerPush = notifications.first,
       let removedAccountString = removedSignerPush.request.content.userInfo["account"] as? String
    {
      let removedAccountData = Data(removedAccountString.utf8)
      do {
        removedAccount = try JSONDecoder().decode(UserAccountFromPush.self, from: removedAccountData)
      } catch {
        Logger.notifications.error("Failed to receive account")
      }
    }
    return removedAccount
  }
  
  private func checkIfNotificationWithTransactionForDelete(notification: UNNotification, removedAccount: UserAccountFromPush, notificationsForDelete: inout [UNNotification]) {
    if let transactionString = notification.request.content.userInfo["transaction"] as? String {
      let data = Data(transactionString.utf8)
      do {
        let transaction = try JSONDecoder().decode(Transaction.self, from: data)
        
        if let xdrSourceList = transaction.xdrSourceList, xdrSourceList.contains(removedAccount.address) {
          notificationsForDelete.append(notification)
        }
      } catch {
        Logger.notifications.error("Failed to receive transaction")
      }
    }
  }
  
  private func checkIfNotificationForDelete(notification: UNNotification, removedAccount: UserAccountFromPush, notificationsForDelete: inout [UNNotification]) {
    if let accountString = notification.request.content.userInfo["account"] as? String {
      let accountData = Data(accountString.utf8)
      do {
        let account = try JSONDecoder().decode(UserAccountFromPush.self, from: accountData)
        if account.address == removedAccount.address {
          notificationsForDelete.append(notification)
        }
      } catch {
        Logger.notifications.error("Failed to receive account")
      }
    }
  }
}
