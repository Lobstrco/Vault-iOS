import Foundation
import UIKit
import FirebaseMessaging

enum AccountStatus: Int {
  case created = 2
  case waitingToBecomeSinger = 1
  case notCreated = 0
}

struct ApplicationCoordinatorHelper {
  
  static func clearKeychain() {
    let secItemClasses = [kSecClassGenericPassword,
                          kSecClassInternetPassword,
                          kSecClassCertificate,
                          kSecClassKey,
                          kSecClassIdentity]
    for secItemClass in secItemClasses {
      let dictionary = [kSecClass as String: secItemClass]
      SecItemDelete(dictionary as CFDictionary)
    }
  }
  
  static func logout() {
    if let fcmToken = Messaging.messaging().fcmToken {
      NotificationsService().unregisterDeviceForNotifications(with: fcmToken)
    } else {      
      Logger.notifications.error("Failed to unregister device with error")
    }
    
    UserDefaultsHelper.accountStatus = .notCreated
    UserDefaultsHelper.isNotificationsEnabled = false    
    ApplicationCoordinatorHelper.clearKeychain()
    
    NotificationManager().setNotificationBadge(badgeNumber: 0)
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
      else { return }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      appDelegate.applicationCoordinator.showMenuScreen()
    }
  }
}
