import Foundation
import os

///
/// You can ignore the `privacy` arguments passed to the protocol methods if
/// they are not applicable to your type's log message representation.
/// Otherwise, your implementation should vary the format strings used based
/// on the indicated privacy setting.
///
/// The method variant that includes source location arguments will be called
/// if the log method (or the global setting) included the option to reveal
/// source location in the logs. This is a stopgap measure until OSLog supports
/// showing source locations in logs originating from Swift code.
public protocol CustomLogRepresentable {
  func logRepresentation(privacy: OSLog.Privacy, logType: OSLogType) -> LogMessage
  func logRepresentation(privacy: OSLog.Privacy,
                         file: String,
                         function: String,
                         line: Int,
                         logType: OSLogType) -> LogMessage
}

/// The customized representation of a type, used when configuring os_log inputs.
public struct LogMessage {
  /// The C-style format string.
  public let format: StaticString

  /// The argument list (what you would otherwise pass as a comma-delimited
  /// list of variadic arguments to `os_log`).
  ///
  /// - Warning: CustomLogRepresentable can only be
  /// initialized with an arg list containing up to nine items. Attempting to
  /// initialize with more than nine arguments will trip an assertion.
  public let args: [CVarArg]

  /// Primary Initializer
  public init(_ format: StaticString, _ args: CVarArg...) {
    assert(args.count < 10,
           "The Swift overlay of os_log prevents this OSLog extension from accepting an unbounded number of args.")
    self.format = format
    self.args = args
  }

  /// Convenience initializer.
  ///
  /// Use this initializer if you are forwarding a `CVarArg...` list from
  /// a calling Swift function and need to prevent the compiler from treating
  /// a single value as an implied array containing that single value, e.g.
  /// from an infering `Array<Int>` from a single `Int` argument.
  public init(format: StaticString, array args: [CVarArg]) {
    assert(args.count < 10,
           "The Swift overlay of os_log prevents this OSLog extension from accepting an unbounded number of args.")
    self.format = format
    self.args = args
  }
}

@inlinable
public func getPublicStaticString(for logType: OSLogType) -> StaticString {
  if logType == .default {
    return "⚪️ %{public}@"
  }
  if logType == .info {
    return "🔵 %{public}@"
  }
  if logType == .debug {
    return "☑️ %{public}@"
  }
  if logType == .error {
    return "🔶 %{public}@"
  }
  return "🔴 %{public}@"
}

@inlinable
public func getPrivateStaticString(for logType: OSLogType) -> StaticString {
  if logType == .default {
    return "⚪️ %{private}@"
  }
  if logType == .info {
    return "🔵 %{private}@"
  }
  if logType == .debug {
    return "☑️ %{private}@"
  }
  if logType == .error {
    return "🔶 %{private}@"
  }
  return "🔴 %{private}@"
}

@inlinable
public func getPublicStaticStringWithSourceLocation(for logType: OSLogType) -> StaticString {
  if logType == .default {
    return "⚪️ %{public}@ \nℹ️ %{public}@.%{public}@:%ld"
  }
  if logType == .info {
    return "🔵 %{public}@ \nℹ️ %{public}@.%{public}@:%ld"
  }
  if logType == .debug {
    return "☑️ %{public}@ \nℹ️ %{public}@.%{public}@:%ld"
  }
  if logType == .error {
    return "🔶 %{public}@ \nℹ️ %{public}@.%{public}@:%ld"
  }
  return "🔴 %{public}@ \nℹ️ %{public}@.%{public}@:%ld"
}

@inlinable
public func getPrivateStaticStringWithSourceLocation(for logType: OSLogType) -> StaticString {
  if logType == .default {
    return "⚪️ %{private}@ \nℹ️ %{private}@.%{private}@:%ld"
  }
  if logType == .info {
    return "🔵 %{private}@ \nℹ️ %{private}@.%{private}@:%ld"
  }
  if logType == .debug {
    return "☑️ %{private}@ \nℹ️ %{private}@.%{private}@:%ld"
  }
  if logType == .error {
    return "🔶 %{private}@ \nℹ️ %{private}@.%{private}@:%ld"
  }
  return "🔴 %{private}@ \nℹ️ %{private}@.%{private}@:%ld"
}


extension CustomLogRepresentable {
  @inlinable
  public func logRepresentation(privacy: OSLog.Privacy, logType: OSLogType) -> LogMessage {
    switch privacy {
    case .visible:
      return LogMessage(getPublicStaticString(for: logType), logDescription)
    case .redacted:
      return LogMessage(getPrivateStaticString(for: logType), logDescription)
    }
  }

  @inlinable
  public func logRepresentation(privacy: OSLog.Privacy, file: String, function: String, line: Int, logType: OSLogType) -> LogMessage {
    switch privacy {
    case .visible:
      return LogMessage(getPublicStaticStringWithSourceLocation(for: logType), logDescription, file, function, line )
    case .redacted:
      return LogMessage(getPrivateStaticStringWithSourceLocation(for: logType), logDescription, file, function, line)
    }
  }

  @usableFromInline
  func logRepresentation(includeSourceLocation: Bool, privacy: OSLog.Privacy, file: String, function: String, line: Int, logType: OSLogType) -> LogMessage {
    if includeSourceLocation {
      let filename = file.split(separator: "/").last.flatMap { String($0) } ?? file
      return logRepresentation(privacy: privacy, file: filename, function: function, line: line, logType: logType)
    } else {
      return logRepresentation(privacy: privacy, logType: logType)
    }
  }

  @usableFromInline
  var logDescription: String {
    let value: Any = (self as? AnyLoggable)?.loggableValue ?? self
    if let string = value as? String {
      return string
    }
    #if DEBUG
    if let custom = value as? CustomDebugStringConvertible {
      return custom.debugDescription
    }
    #endif
    if let convertible = value as? CustomStringConvertible {
      return convertible.description
    }
    return "\(value)"
  }
}

struct AnyLoggable: CustomLogRepresentable {
  let loggableValue: Any

  init(_ value: Any) {
    loggableValue = value
  }
}

extension NSError: CustomLogRepresentable {}
extension String: CustomLogRepresentable {}
extension Bool: CustomLogRepresentable {}
extension Int: CustomLogRepresentable {}
extension UInt: CustomLogRepresentable {}
extension Double: CustomLogRepresentable {}
extension Float: CustomLogRepresentable {}
