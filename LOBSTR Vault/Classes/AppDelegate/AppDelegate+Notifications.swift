import UserNotifications
import FirebaseMessaging

extension AppDelegate: UNUserNotificationCenterDelegate {
  
  func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler _: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    applicationCoordinator.postNotification(accordingTo: userInfo)
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
  {
    let userInfo = notification.request.content.userInfo
    applicationCoordinator.postNotification(accordingTo: userInfo)
    completionHandler([.alert, .sound])
  }
}

extension AppDelegate: MessagingDelegate {
  func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String) {
//    print("fcmToken: \(fcmToken)")
  }
  
}
