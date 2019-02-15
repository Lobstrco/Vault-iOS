import UserNotifications
import FirebaseMessaging

extension AppDelegate {

  public func registerForRemoteNotifications(isStart: Bool = true) {

    Messaging.messaging().delegate = self
    UNUserNotificationCenter.current().delegate = self

    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
      guard granted else { return }
    }

    UIApplication.shared.registerForRemoteNotifications()
    
    if !isStart {
      sendFCMTokenToServer()
    }
  }

  func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("APNS Error:\n\(error.localizedDescription)")
  }

  func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    let messagingAPNSTokenType: MessagingAPNSTokenType = .prod
    Messaging.messaging().setAPNSToken(deviceToken, type: messagingAPNSTokenType)
  }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {

  func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler _: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    postNotification(accordingTo: userInfo)
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
  {
    let userInfo = notification.request.content.userInfo
    postNotification(accordingTo: userInfo)
    completionHandler([.alert, .sound])
  }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
  func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String) {
    sendFCMTokenToServer()
  }
}

// MARK: - Private

extension AppDelegate {

  private func sendFCMTokenToServer() {
    guard let fcmToken = Messaging.messaging().fcmToken else { return }
    print("FCM TOKEN: \(fcmToken)")
    let notificationService = NotificationsService()
    notificationService.registerDeviceForNotifications(with: fcmToken)
  }
  
  private func postNotification(accordingTo userInfo: [AnyHashable : Any]) {
    let eventType =  userInfo["event_type"] as? String
    if eventType == "added_new_transaction" {
      NotificationCenter.default.post(name: .didChangeTransactionList, object: nil)
    }
  }
}
