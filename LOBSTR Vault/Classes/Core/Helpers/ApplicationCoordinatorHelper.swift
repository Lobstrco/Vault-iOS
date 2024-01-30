import Foundation
import UIKit
import FirebaseMessaging

enum AccountStatus: Int {
  case createdByDefault = 2
  case createdWithTangem = 1
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
    NotificationManager().unregisterAllAccountsForRemoteNotifications()
    
    UserDefaultsHelper.accountStatus = .notCreated
    UserDefaultsHelper.pushNotificationsStatuses = [:]
    UserDefaultsHelper.promtForTransactionDecisionsStatuses = [:]
    UserDefaultsHelper.isPromtTransactionDecisionsEnabled = true
    UserDefaultsHelper.isICloudSynchronizationEnabled = false
    UserDefaultsHelper.isICloudSyncAdviceShown = false
    UserDefaultsHelper.isICloudSynchronizationActive = false
    //UserDefaultsHelper.isNotificationsEnabled = false
    UserDefaultsHelper.tangemCardId = nil
    ApplicationCoordinatorHelper.clearKeychain()
    UserDefaultsHelper.badgesCounter = 0
    UserDefaultsHelper.actualTransactionNumber = 0
    
    NotificationManager().setNotificationBadge(badgeNumber: 0)
    BiometricAuthManagerImpl().isBiometricAuthEnabled = false
    
    AccountsStorageHelper.clear()
    CloudKitNicknameHelper.clear()
       
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
    else { return }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      appDelegate.applicationCoordinator.showMenuScreen()
    }
  }
}
