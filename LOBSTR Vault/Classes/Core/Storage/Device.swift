import Foundation
import LocalAuthentication

public enum Device {
  public static var isSimulator: Bool {
    return TARGET_OS_SIMULATOR != 0
  }
  
  public static var hasTouchID: Bool {
    if #available(OSX 10.12.2, *) {
      return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                           error: nil)
    } else {
      return false
    }
  }
  
  public static var hasSecureEnclave: Bool {
    return hasTouchID && !isSimulator
  }
}
