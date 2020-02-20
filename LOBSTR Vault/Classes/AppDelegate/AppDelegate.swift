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
    applicationCoordinator.start(appDelegate: self)
    firebaseSetup()
    UITabBar.appearance().tintColor = Asset.Colors.main.color    
    
    return true
  }
  
  func firebaseSetup() {
    var filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
    if Environment.buildType == .qa {
      filePath = Bundle.main.path(forResource: "GoogleService-Info-QA", ofType: "plist")
    }
        
    guard let path = filePath, let options = FirebaseOptions(contentsOfFile: path) else {
      Logger.firebase.error("Couldn't configure firebase")
      return
    }
    FirebaseApp.configure(options: options)
  }
  
  func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    applicationCoordinator.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
  }
  
  func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    Logger.notifications.error("Failed to register device with error: \(error)")  
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
