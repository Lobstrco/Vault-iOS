import Foundation
import UserNotifications
import UIKit
import FirebaseMessaging

class NotificationManager {
  
  var isRegisteredForRemoteNotifications: Bool {
    return UIApplication.shared.isRegisteredForRemoteNotifications
  }
  
  func requestAuthorization(completionHandler: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { granted, error in
      completionHandler(granted)
    }
  }
  
  func register() {
    UIApplication.shared.registerForRemoteNotifications()
    sendFCMTokenToServer()
  }
  
  func unregister() {
    UIApplication.shared.unregisterForRemoteNotifications()
    
    guard let fcmToken = Messaging.messaging().fcmToken else {
      print("Couldn't unregister device")
      return
    }
   
    NotificationsService().unregisterDeviceForNotifications(with: fcmToken)
  }
  
  func setAPNSToken(deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
  
  func sendFCMTokenToServer() {
    guard let fcmToken = Messaging.messaging().fcmToken else { return }
    NotificationsService().registerDeviceForNotifications(with: fcmToken)
  }
  
  func postNotification(accordingTo userInfo: [AnyHashable : Any]) {
    let eventType =  userInfo["event_type"] as? String
    if eventType == "added_new_transaction" {
      NotificationCenter.default.post(name: .didChangeTransactionList, object: nil)
    }
  }
}
