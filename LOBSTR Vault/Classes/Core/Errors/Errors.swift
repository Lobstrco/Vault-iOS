public protocol ErrorDisplayable: Error {
  typealias ErrorDisplayData = (titleKey: String, messageKey: String)
  var errorKey: String { get }
  var displayData: ErrorDisplayData { get }
}

extension ErrorDisplayable {
  public var displayData: ErrorDisplayData {
    return (String(format: "%@_TITLE", errorKey), String(format: "%@_MESSAGE", errorKey))
  }
}

struct VaultError: Error, ErrorDisplayable {
  internal let internalError: Error
  private(set) var errorKey: String
  
  public init(error: Error) {
    internalError = error
    
    if let keyableError = error as? ErrorDisplayable {
      errorKey = keyableError.errorKey
    } else {
      errorKey = "UNKNOWN_ERROR"
    }
  }
}

extension VaultError {
  public enum TransactionError: ErrorDisplayable {
    case invalidTransaction
    case outOfOperationRange
    
    public var errorKey: String {
      switch self {
      case .invalidTransaction: return "INVALID_TRANSACTION"
      case .outOfOperationRange: return "OUT_OF_OPERATION_RANGE"
      }
    }
  }
  
  public enum OperationError: ErrorDisplayable {
    case invalidOperation
    
    public var errorKey: String {
      switch self {
      case .invalidOperation: return "INVALID_OPERATION"
      }
    }
  }
  
  public enum ScreenTransitionError: ErrorDisplayable {
    case invalidTransition
    
    public var errorKey: String {
      switch self {
      case .invalidTransition: return "INVALID_TRANSITION"
      }
    }
  }
  
  public enum VaultStorageError: ErrorDisplayable {
    case keychainDataNotFound
    case decryptionFailed
    
    public var errorKey: String {
      switch self {
      case .keychainDataNotFound: return ""
      case .decryptionFailed: return ""
      }
    }
  }
  
  public enum BiometricError: ErrorDisplayable {
    case notAvailable
    case authenticationFailed
    case cancelled
    case fallback
    case undefined
    
    public var errorKey: String {
      switch self {
      case .notAvailable: return "BIOMETRIC_NOT_AVAILABLE"
      case .authenticationFailed: return "BIOMETRIC_NOT_VERIFIED_IDENTITY"
      case .cancelled: return "BIOMETRIC_PRESSED_CANCEL"
      case .fallback: return "BIOMETRIC_PRESSED_PASSWORD"
      case .undefined: return "BIOMETRIC_NOT_CONFIGURED"
      }
    }
  }
}
