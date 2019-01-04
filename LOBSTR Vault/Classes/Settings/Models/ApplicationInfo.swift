import Foundation

public enum ApplicationInfo {
  public static var version: String {
    let bundle = Bundle.main
    let shortVersion = "CFBundleShortVersionString"
    let bundleVersion = "CFBundleVersion"

    guard let appVersionString = bundle.object(forInfoDictionaryKey: shortVersion) as? String,
      let appBuildString = bundle.object(forInfoDictionaryKey: bundleVersion) as? String
    else { return "" }

    return "\(appVersionString) (\(appBuildString))"
  }
}

