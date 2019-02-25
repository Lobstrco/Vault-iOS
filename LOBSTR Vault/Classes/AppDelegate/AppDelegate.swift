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
    
    FirebaseApp.configure()
    applicationCoordinator.start()
    return true
  }
  
  func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    applicationCoordinator.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
  }
  
  func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("APNS Error:\n\(error.localizedDescription)")    
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    guard let frame = window?.frame else { return }
    multiTaskImageView = UIImageView(frame: frame)
    multiTaskImageView?.image = Asset.Other.bgMultitask.image
    
    guard let multiTaskImageView = multiTaskImageView else { return }
    window?.addSubview(multiTaskImageView)
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    if multiTaskImageView != nil {
      multiTaskImageView?.removeFromSuperview()
      multiTaskImageView = nil
    }
  }
}
