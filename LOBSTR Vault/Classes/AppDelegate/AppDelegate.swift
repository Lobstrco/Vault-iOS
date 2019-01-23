import Firebase
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  lazy var applicationCoordinator: ApplicationCoordinator = {
    ApplicationCoordinator(window: window)
  }()

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//    FirebaseApp.configure()
    
    //clearKeychain()

    applicationCoordinator.startUserFlow()

    return true
  }
}

extension AppDelegate {
  func clearKeychain() {
    let secItemClasses = [kSecClassGenericPassword,
                          kSecClassInternetPassword,
                          kSecClassCertificate,
                          kSecClassKey,
                          kSecClassIdentity]
    for secItemClass in secItemClasses {
      let dictionary = [kSecClass as String: secItemClass]
      SecItemDelete(dictionary as CFDictionary)
    }
  }
}
