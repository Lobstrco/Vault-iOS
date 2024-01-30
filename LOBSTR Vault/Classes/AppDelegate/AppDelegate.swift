import Firebase
import UIKit

import UserNotifications
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  var multiTaskImageView: UIImageView?
  var backgroundView: UIView?
  
  lazy var applicationCoordinator: ApplicationCoordinator = {
    ApplicationCoordinator(window: window)
  }()

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    application.registerForRemoteNotifications()
    firebaseSetup()
    countAppLaunches()
    applicationCoordinator.start(appDelegate: self)
    
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
    
    if Environment.buildType != .release {
      //Crashlytics.sharedInstance().debugMode = true
    }
  }
  
  func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    applicationCoordinator.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
  }
  
  func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    Logger.notifications.error("Failed to register device with error: \(error)")
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    let number = UserDefaultsHelper.badgesCounter == 0 ? -1 : UserDefaultsHelper.badgesCounter
    UIApplication.shared.applicationIconBadgeNumber = number
    if let topController = UIApplication.shared.keyWindow?.rootViewController {
      topController.dismiss(animated: false, completion: nil)
    }
    guard let frame = window?.frame else { return }
    backgroundView = UIView(frame: frame)
    backgroundView?.backgroundColor = Asset.Colors.main.color
    multiTaskImageView = UIImageView(image: Asset.Other.fullLogo.image)
    multiTaskImageView?.tintColor = Asset.Colors.white.color
    
    guard let backgroundView = backgroundView, let multiTaskImageView = multiTaskImageView else { return }
    multiTaskImageView.center = CGPoint(x: backgroundView.frame.size.width / 2,
                                        y: backgroundView.frame.size.height / 2)
    backgroundView.addSubview(multiTaskImageView)
    window?.addSubview(backgroundView)
    window?.endEditing(true)
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    if backgroundView != nil, multiTaskImageView != nil {
      multiTaskImageView?.removeFromSuperview()
      multiTaskImageView = nil
      backgroundView?.removeFromSuperview()
      backgroundView = nil
    }
    PinHelper.tryToShowPinEnterViewController()
  }
  
  func countAppLaunches() {
    var appLaunchesCounter = UserDefaultsHelper.appLaunchesCounter
    let appLaunchesCounterEnabled = UserDefaultsHelper.isAppLaunchesCounterEnabled
    
    if appLaunchesCounterEnabled, appLaunchesCounter < 6 {
      appLaunchesCounter += 1
      UserDefaultsHelper.appLaunchesCounter = appLaunchesCounter
    }
    UserDefaults.standard.synchronize()
  }
}
