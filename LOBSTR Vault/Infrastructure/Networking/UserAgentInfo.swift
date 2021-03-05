//

import Foundation
import UIKit

final class UserAgentInfo {
  static func getFormattedUserAgent() -> String {
    let appName =
      (Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String).uppercased()

    let appVersion = ApplicationInfo.version

    let deviceName = UIDevice.modelName

    let systemName = UIDevice().systemName
    let systemVersion = UIDevice().systemVersion

    return "\(appName)/\(appVersion) (\(deviceName); \(systemName) \(systemVersion))"
  }
}
