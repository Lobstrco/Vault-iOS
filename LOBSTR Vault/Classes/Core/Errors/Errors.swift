import stellarsdk

public protocol ErrorDisplayable: Error {
  typealias ErrorDisplayData = (titleKey: String, messageKey: String)
  var errorKey: String { get }
  var displayData: ErrorDisplayData { get }
}

extension ErrorDisplayable {
  public var displayData: ErrorDisplayData {
    return (String(format: "%@_title", errorKey), String(format: "%@_message", errorKey))
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
      errorKey = L10n.errorUnknown
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
      case .notAvailable: return L10n.errorBiometricNotAvailable
      case .cancelled: return L10n.errorBiometricPressedCancel
      case .fallback: return L10n.errorBiometricPressedPassword
      case .authenticationFailed: return L10n.errorBiometricNotVerifiedIdentity
      case .undefined: return L10n.errorBiometricNotConfigured
      }
    }
  }
}

extension HorizonRequestError: ErrorDisplayable {
  public var errorKey: String {
    switch self {
    case HorizonRequestError.requestFailed(_): return L10n.horizonErrorRequestFailed
    case HorizonRequestError.badRequest(_, _): return L10n.horizonErrorBadRequest
    case HorizonRequestError.emptyResponse: return L10n.horizonErrorInvalidResponse
    case HorizonRequestError.parsingResponseFailed(_): return L10n.horizonErrorInvalidResponse
    case HorizonRequestError.unauthorized(_): return L10n.horizonErrorUnauthorized
    case HorizonRequestError.forbidden(_, _): return L10n.horizonErrorForbidden
    case HorizonRequestError.notFound(_, _): return L10n.horizonErrorNotFound
    case HorizonRequestError.notAcceptable(_, _): return L10n.horizonErrorNotAcceptable
    case HorizonRequestError.beforeHistory(_, _): return L10n.horizonErrorBeforeHistory
    case HorizonRequestError.rateLimitExceeded(_, _): return L10n.horizonErrorRateLimit
    case HorizonRequestError.internalServerError(_, _): return L10n.horizonErrorInternalServer
    case HorizonRequestError.notImplemented(_, _): return L10n.horizonErrorNotImplemented
    case HorizonRequestError.staleHistory(_, _): return L10n.horizonErrorStaleHistory
    case HorizonRequestError.errorOnStreamReceive(_): return L10n.horizonErrorStream
    }
  }
}
