import Firebase
import UIKit

import UserNotifications
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  var multiTaskImageView: UIImageView?
  
  lazy var applicationCoordinator: ApplicationCoordinator = {
    ApplicationCoordinator(window: window)
  }()

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    application.registerForRemoteNotifications()
    FirebaseApp.configure()
    applicationCoordinator.start(appDelegate: self)
    
    UITabBar.appearance().tintColor = Asset.Colors.main.color
    
    return true
  }
  
  func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    applicationCoordinator.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
  }
  
  func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("APNS Error:\n\(error.localizedDescription)")    
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    guard let frame = window?.frame else { return }
    multiTaskImageView = UIImageView(frame: frame)
    multiTaskImageView?.image = Asset.Other.bgMultitask.image
    
    guard let multiTaskImageView = multiTaskImageView else { return }
    window?.addSubview(multiTaskImageView)
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    if multiTaskImageView != nil {
      multiTaskImageView?.removeFromSuperview()
      multiTaskImageView = nil
    }
  }
}
