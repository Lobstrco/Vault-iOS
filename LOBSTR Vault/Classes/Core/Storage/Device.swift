import Foundation
import LocalAuthentication

public enum Device {
  public static var isSimulator: Bool {
    return TARGET_OS_SIMULATOR != 0
  }
  
  public static var hasTouchID: Bool {
    switch biometricType {
    case .touch:
      return true
    default:
      return false
    }
  }
  
  public static var hasSecureEnclave: Bool {
    return hasTouchID && !isSimulator
  }
  
  public static var biometricType: BiometricType {
    let authContext = LAContext()
    if #available(iOS 11, *) {
      _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                        error: nil)
      switch authContext.biometryType {
      case .none:
        return .none
      case .touchID:
        return .touch
      case .faceID:
        return .face
      }
    } else {
      return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                           error: nil) ? .touch : .none
    }
  }
}

public enum BiometricType {
  case none
  case touch
  case face
  
  var name: String {
    switch self {
    case .touch:
      return "Touch ID"
    case .face:
      return "Face ID"
    case .none:
      return ""
    }
  }
}
