import UIKit

public enum LobstrCheckResult {
  case installed
  case notInstalled
}

public protocol URLOpener: AnyObject {
  func canOpenURL(_ url: URL) -> Bool
}

extension UIApplication: URLOpener {}

public protocol LobstrChecker: AnyObject {
  init(urlOpener: URLOpener)
  func checkLobstr() -> LobstrCheckResult
}

// Checks if LOBSTR Vault is installed on the device and can be used as a signer.
public final class LobstrCheckerImpl: LobstrChecker {
  public let urlOpener: URLOpener
  

  public init(urlOpener: URLOpener = UIApplication.shared) {
    self.urlOpener = urlOpener
  }

  public func checkLobstr() -> LobstrCheckResult {
    let url = URL(string: Constants.lobstrScheme)!

    guard urlOpener.canOpenURL(url) else {
      return .notInstalled
    }
    
    return .installed
  }
}


