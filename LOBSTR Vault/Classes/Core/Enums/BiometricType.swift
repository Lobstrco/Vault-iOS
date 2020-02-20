import Foundation

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
      return "Biometric ID"
    }
  }
}
