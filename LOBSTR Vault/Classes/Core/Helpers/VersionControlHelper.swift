import Foundation
import UIKit

struct VersionControlHelper {
  static let versionControlService = VersionControlService()
  static let appLink = "itms-apps://itunes.apple.com/app/id1452248529"
  
  static let currentAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
  
  static func checkAppVersion(showAlertImmediately: Bool,
                              completion: @escaping ([String: String]) -> Void)
  {
    versionControlService.getAppVersion { result in
      switch result {
      case .success(let response):
        guard let currentVersion = response.currentVersion,
              let minVersion = response.minVersion,
              let recommendedVersion = response.recommendedVersion else { return }
        
        let versions: Dictionary = ["min_app_version": minVersion,
                                    "recommended": recommendedVersion,
                                    "current_version": currentVersion]
        if showAlertImmediately {
          let compareWithCurrent = currentAppVersion.compare(currentVersion,
                                                             options: .numeric)
          if compareWithCurrent == .orderedSame {
            UserDefaults.standard
              .setValue(false,
                        forKey: UserDefaultsHelper.showUpdateAdviceKey)
            completion(versions)
            return
          } else if compareWithCurrent == .orderedDescending {
            UserDefaults.standard
              .setValue(false,
                        forKey: UserDefaultsHelper.showUpdateAdviceKey)
            completion(versions)
            return
          }
        
          let compareWithRecommended = currentAppVersion.compare(recommendedVersion,
                                                                 options: .numeric)
          if compareWithRecommended == .orderedSame ||
            compareWithRecommended == .orderedDescending
          {
            VersionControlHelper.showUpdateAdvice()
            completion(versions)
            return
          }
        
          let compareWithMinimum = currentAppVersion.compare(minVersion,
                                                             options: .numeric)
          if compareWithMinimum == .orderedSame ||
            compareWithMinimum == .orderedDescending
          {
            VersionControlHelper.showPeriodicUpdateAdvice()
          } else if compareWithMinimum == .orderedAscending {
            switch UserDefaultsHelper.accountStatus {
            case .createdByDefault:
              VersionControlHelper.showForceUpdate()
            default: break
            }
            //VersionControlHelper.showForceUpdate()
          }
        }
        completion(versions)
      case .failure:
        completion(Dictionary())
      }
    }
  }
  
  static func showUpdateAdvice() {

    let showUpdateAdvice =
      UserDefaults.standard.bool(forKey: UserDefaultsHelper.showUpdateAdviceKey)
    
    if !showUpdateAdvice {
      
      UserDefaults.standard
        .setValue(true,
                  forKey: UserDefaultsHelper.showUpdateAdviceKey)
      
      let alertController = UIAlertController(title: L10n.textAppUpdateTitleWeak,
                                              message: L10n.textAppUpdateMessageWeak,
                                              preferredStyle: .alert)
      let updateAction = UIAlertAction(title: L10n.buttonTextAppUpdate,
                                       style: .default) { _ in
        if let url = URL(string: appLink) {
          UIApplication.shared.open(url)
        }
      }
      let skipAction = UIAlertAction(title: L10n.buttonTextAppUpdateSkip,
                                     style: .cancel, handler: nil)
      alertController.addAction(updateAction)
      alertController.addAction(skipAction)

      if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
          topController = presentedViewController
        }
        topController.present(alertController, animated: true, completion: nil)
      }
      UserDefaultsHelper.isAppLaunchesCounterEnabled = false
//      UserDefaults.standard.setValue(false,
//                                     forKey: UserDefaultsHelper.appLaunchesCounterEnabledKey)
    }
  }
  
  static func showPeriodicUpdateAdvice() {
    let launchCounter = UserDefaultsHelper.appLaunchesCounter
    let launchCounterEnabled = UserDefaultsHelper.isAppLaunchesCounterEnabled
    
    if !launchCounterEnabled ||
      launchCounter == 6 {
      UserDefaultsHelper.appLaunchesCounter = 0
      UserDefaultsHelper.isAppLaunchesCounterEnabled = true
      
      let alertController = UIAlertController(title: L10n.textAppUpdateTitleWeak,
                                              message: L10n.textAppUpdateMessageWeak,
                                              preferredStyle: .alert)
      let updateAction = UIAlertAction(title: L10n.buttonTextAppUpdate,
                                       style: .default) { _ in
        if let url = URL(string: appLink) {
          UIApplication.shared.open(url)
        }
      }
      let skipAction = UIAlertAction(title: L10n.buttonTextAppUpdateSkip,
                                     style: .cancel, handler: nil)
      alertController.addAction(updateAction)
      alertController.addAction(skipAction)
      
      if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
          topController = presentedViewController
        }
        topController.present(alertController, animated: true, completion: nil)
      }
    }
  }
  
  static func showForceUpdate() {
    let alertController = UIAlertController(title: L10n.textAppUpdateTitleRequired,
                                            message: L10n.textAppUpdateMessageRequired,
                                            preferredStyle: .alert)
    let updateAction = UIAlertAction(title: L10n.buttonTextAppUpdate,
                                     style: .default) { _ in
      if let url = URL(string: appLink) {
        UIApplication.shared.open(url)
      }
    }
    alertController.addAction(updateAction)

    if var topController = UIApplication.shared.keyWindow?.rootViewController {
      while let presentedViewController = topController.presentedViewController {
        topController = presentedViewController
      }
      topController.present(alertController, animated: true, completion: nil)
      UserDefaultsHelper.isAppLaunchesCounterEnabled = false
    }
  }
  
  static func checkIfAlertViewHasPresented() -> UIAlertController? {
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
          while let presentedViewController = topController.presentedViewController {
              topController = presentedViewController
          }
          if topController is UIAlertController {
             return (topController as! UIAlertController)
          } else {
             return nil
          }
      }
      return nil
  }

}
