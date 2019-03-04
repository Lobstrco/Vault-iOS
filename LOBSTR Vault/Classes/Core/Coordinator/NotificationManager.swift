import Foundation
import UserNotifications
import UIKit
import FirebaseMessaging

class NotificationManager {

  var isRegisteredForRemoteNotifications: Bool {
    return UIApplication.shared.isRegisteredForRemoteNotifications
  }
  
  init() {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    Messaging.messaging().delegate = appDelegate
    UNUserNotificationCenter.current().delegate = appDelegate
  }
  
  func register() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { granted, error in
      guard granted else {
//        print("FLOW: REGISTER DENIED")
        UserDefaultsHelper.isNotificationsEnabled = false
        return
      }
//      print("FLOW: REGISTER")
      DispatchQueue.main.async {
        UserDefaultsHelper.isNotificationsEnabled = true
        UIApplication.shared.registerForRemoteNotifications()
      }      
    }
  }
  
  func unregister() {
//    print("FLOW: UNREGISTER")
    UIApplication.shared.unregisterForRemoteNotifications()
  }
  
  func setAPNSToken(deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    let messagingAPNSTokenType: MessagingAPNSTokenType = .prod
    Messaging.messaging().setAPNSToken(deviceToken, type: messagingAPNSTokenType)
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
