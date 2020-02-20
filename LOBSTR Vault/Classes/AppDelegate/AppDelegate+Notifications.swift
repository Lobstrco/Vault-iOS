import UserNotifications
import FirebaseMessaging

extension AppDelegate: UNUserNotificationCenterDelegate {
  
  func userNotificationCenter(_: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler _: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    applicationCoordinator.postNotification(accordingTo: userInfo)
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    applicationCoordinator.postNotification(accordingTo: userInfo)
    applicationCoordinator.setNotificationBadge(accordingTo: userInfo)
    completionHandler([.alert, .sound, .badge])
  }
}

extension AppDelegate: MessagingDelegate {
  func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String) {
    checkNotificationAvailability()
  }
  
  private func checkNotificationAvailability() {
    let accountStatus = UserDefaultsHelper.accountStatus
    let notificationManager = NotificationManager()
    
    guard accountStatus != .notCreated else {
      return
    }
    
    notificationManager.requestAuthorization() { isGranted in
      if !isGranted {
        UserDefaultsHelper.isNotificationsEnabled = false
      }
      
      if UserDefaultsHelper.isNotificationsEnabled {
        notificationManager.sendFCMTokenToServer()
      }
    }
  }
}
