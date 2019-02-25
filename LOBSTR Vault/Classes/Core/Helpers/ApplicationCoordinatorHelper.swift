import Foundation
import UIKit
import FirebaseMessaging

enum AccountStatus: Int {
  case created = 2
  case waitingToBecomeSinger = 1
  case notCreated = 0
}

struct ApplicationCoordinatorHelper {
  
  static let accountCreatedKey = "isAccountCreated"
  static let pushNotificationKey = "isPushNotificationsEnabled"
  
  static var isNotificationsEnabled: Bool {
    get { return UserDefaults.standard.bool(forKey: ApplicationCoordinatorHelper.pushNotificationKey) }
    set { UserDefaults.standard.set(newValue, forKey: ApplicationCoordinatorHelper.pushNotificationKey) }
  }
  
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
  
  static func setAccountStatus(_ status: AccountStatus) {
    UserDefaults.standard.set(status.rawValue, forKey: ApplicationCoordinatorHelper.accountCreatedKey)
  }
  
  static func getAccountStatus() -> AccountStatus {
    let accountStatusRawValue =  UserDefaults.standard.integer(forKey: ApplicationCoordinatorHelper.accountCreatedKey)
    return AccountStatus(rawValue: accountStatusRawValue) ?? .notCreated
  }
  
  static func logout() {
    if let fcmToken = Messaging.messaging().fcmToken {
      NotificationsService().unregisterDeviceForNotifications(with: fcmToken)
    } else {
      print("Couldn't unregister device")
    }
    
    ApplicationCoordinatorHelper.setAccountStatus(.notCreated)
    ApplicationCoordinatorHelper.isNotificationsEnabled = false
    ApplicationCoordinatorHelper.clearKeychain()
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
      else { return }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      appDelegate.applicationCoordinator.showMenuScreen()
    }
  }
}
