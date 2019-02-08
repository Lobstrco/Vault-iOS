import Firebase
import UIKit

import UserNotifications
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  lazy var applicationCoordinator: ApplicationCoordinator = {
    ApplicationCoordinator(window: window)
  }()

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    FirebaseApp.configure()
    applicationCoordinator.openRequiredScreen()
    
    let accountStatus = ApplicationCoordinatorHelper.getAccountStatus()
    if accountStatus == .waitingToBecomeSinger || accountStatus == .created {
      registerForRemoteNotifications()
    }
    
    return true
  }
}
