import Foundation
import os

public extension OSLog {
  // MARK: - Nested Types

  enum Options {
    /// The default Privacy setting to use.
    public static var defaultPrivacy: Privacy = {
      #if DEBUG
      return .visible
      #else
      return .redacted
      #endif      
    }()

    /// If `true`, the function, file, and line number will be included in
    /// messages logged using the "foo(value:)" log methods below.
    public static var includeSourceLocationInValueLogs: Bool = {
      #if DEBUG
      return true
      #else
      return false
      #endif
    }()
  }

  /// Controls whether log message content is redacted or visible.
  enum Privacy {
    /// No values will be redacted.
    case visible

    /// Values besides static strings and scalars will be redacted.
    case redacted
  }

  // MARK: - Default

  /// Logs a developer-formatted message using the `.default` type.
  ///
  /// The caller is responsible for including public/private formatting in the
  /// format string, as well as any source location info (line number, etc.).
  ///
  /// - parameter format: A C-style format string.
  ///
  /// - parameter args: A list of arguments to the format string (if any).
  @inlinable
  func log(format: StaticString, args: CVarArg...) {
    // Use the `(format:array:)` variant to prevent the compiler from
    // wrapping a single argument in an array it thinks you implied.
    let representation = LogMessage(format: format, array: args)
    logInternal(representation: representation, type: .default)
  }

  /// Logs a message using the `.default` type.
  ///
  /// - parameter value: The value to be logged. If the value does not already
  /// conform to CustomLogRepresentable, a default implementation will used.
  @inlinable
  func log(_ value: Any,
                  privacy: Privacy = Options.defaultPrivacy,
                  includeSourceLocation: Bool = Options.includeSourceLocationInValueLogs,
                  file: String = #file,
                  function: String = #function,
                  line: Int = #line) {
    logInternal(value: value, privacy: privacy, includeSourceLocation: includeSourceLocation, file: file, function: function, line: line, type: .default)
  }

  // MARK: - Info

  /// Logs a developer-formatted message using the `.info` type.
  ///
  /// The caller is responsible for including public/private formatting in the
  /// format string, as well as any source location info (line number, etc.).
  ///
  /// - parameter format: A C-style format string.
  ///
  /// - parameter args: A list of arguments to the format string (if any).
  @inlinable
  func info(format: StaticString, args: CVarArg...) {
    // Use the `(format:array:)` variant to prevent the compiler from
    // wrapping a single argument in an array it thinks you implied.
    let representation = LogMessage(format: format, array: args)
    logInternal(representation: representation, type: .info)
  }

  /// Logs a message using the `.info` type.
  ///
  /// - parameter value: The value to be logged. If the value does not already
  /// conform to CustomLogRepresentable, a default implementation will used.
  @inlinable
  func info(_ value: Any,
                   privacy: Privacy = Options.defaultPrivacy,
                   includeSourceLocation: Bool = Options.includeSourceLocationInValueLogs,
                   file: String = #file,
                   function: String = #function,
                   line: Int = #line) {
    logInternal(value: value, privacy: privacy, includeSourceLocation: includeSourceLocation, file: file, function: function, line: line, type: .info)
  }

  // MARK: - Debug

  /// Logs the source location of the call site using the `.debug` type.
  @inlinable
  func trace(file: String = #file,
                    function: String = #function,
                    line: Int = #line) {
    let representation = LogMessage("%{public}@ %{public}@ Line %ld", file, function, line)
    logInternal(representation: representation, type: .debug)
  }

  /// Logs a developer-formatted message using the `.debug` type.
  ///
  /// The caller is responsible for including public/private formatting in the
  /// format string, as well as any source location info (line number, etc.).
  ///
  /// - parameter format: A C-style format string.
  ///
  /// - parameter args: A list of arguments to the format string (if any).
  @inlinable
  func debug(format: StaticString, args: CVarArg...) {
    // Use the `(format:array:)` variant to prevent the compiler from
    // wrapping a single argument in an array it thinks you implied.
    let representation = LogMessage(format: format, array: args)
    logInternal(representation: representation, type: .debug)
  }

  /// Logs a message using the `.debug` type.
  ///
  /// - parameter value: The value to be logged. If the value does not already
  /// conform to CustomLogRepresentable, a default implementation will used.
  @inlinable
  func debug(_ value: Any,
                    privacy: Privacy = Options.defaultPrivacy,
                    includeSourceLocation: Bool = Options.includeSourceLocationInValueLogs,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line) {
    logInternal(value: value, privacy: privacy, includeSourceLocation: includeSourceLocation, file: file, function: function, line: line, type: .debug)
  }

  // MARK: - Error

  /// Logs a developer-formatted message using the `.error` type.
  ///
  /// The caller is responsible for including public/private formatting in the
  /// format string, as well as any source location info (line number, etc.).
  ///
  /// - parameter format: A C-style format string.
  ///
  /// - parameter args: A list of arguments to the format string (if any).
  @inlinable
  func error(format: StaticString, args: CVarArg...) {
    // Use the `(format:array:)` variant to prevent the compiler from
    // wrapping a single argument in an array it thinks you implied.
    let representation = LogMessage(format: format, array: args)
    logInternal(representation: representation, type: .error)
  }

  /// Logs a message using the `.error` type.
  ///
  /// - parameter value: The value to be logged. If the value does not already
  /// conform to CustomLogRepresentable, a default implementation will used.
  @inlinable
  func error(_ value: Any,
                    privacy: Privacy = Options.defaultPrivacy,
                    includeSourceLocation: Bool = Options.includeSourceLocationInValueLogs,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line) {
    logInternal(value: value, privacy: privacy, includeSourceLocation: includeSourceLocation, file: file, function: function, line: line, type: .error)
  }

  // MARK: - Fault

  /// Logs a developer-formatted message using the `.fault` type.
  ///
  /// The caller is responsible for including public/private formatting in the
  /// format string, as well as any source location info (line number, etc.).
  ///
  /// - parameter format: A C-style format string.
  ///
  /// - parameter args: A list of arguments to the format string (if any).
  @inlinable
  func fault(format: StaticString, args: CVarArg...) {
    // Use the `(format:array:)` variant to prevent the compiler from
    // wrapping a single argument in an array it thinks you implied.
    let representation = LogMessage(format: format, array: args)
    logInternal(representation: representation, type: .fault)
  }

  /// Logs a message using the `.fault` type.
  ///
  /// - parameter value: The value to be logged. If the value does not already
  /// conform to CustomLogRepresentable, a default implementation will used.
  @inlinable
  func fault(_ value: Any,
                    privacy: Privacy = Options.defaultPrivacy,
                    includeSourceLocation: Bool = Options.includeSourceLocationInValueLogs,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line) {
    logInternal(value: value, privacy: privacy, includeSourceLocation: includeSourceLocation, file: file, function: function, line: line, type: .fault)
  }

  // MARK: - Internal

  @usableFromInline
  internal func logInternal(value: Any,
                            privacy: Privacy,
                            includeSourceLocation: Bool,
                            file: String,
                            function: String,
                            line: Int,
                            type: OSLogType) {
    let loggable = (value as? CustomLogRepresentable) ?? AnyLoggable(value)
    let representation = loggable.logRepresentation(includeSourceLocation: includeSourceLocation, privacy: privacy, file: file, function: function, line: line, logType: type)
    logInternal(representation: representation, type: type)
  }

  @usableFromInline
  internal func logInternal(representation: LogMessage, type: OSLogType) {
    // http://www.openradar.me/33203955
    // Swift doesn't support spread operator
    // Ugly workaround
    let f = representation.format
    let a = representation.args
    switch a.count {
    case 9: os_log(f, log: self, type: type, a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8])
    case 8: os_log(f, log: self, type: type, a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7])
    case 7: os_log(f, log: self, type: type, a[0], a[1], a[2], a[3], a[4], a[5], a[6])
    case 6: os_log(f, log: self, type: type, a[0], a[1], a[2], a[3], a[4], a[5])
    case 5: os_log(f, log: self, type: type, a[0], a[1], a[2], a[3], a[4])
    case 4: os_log(f, log: self, type: type, a[0], a[1], a[2], a[3])
    case 3: os_log(f, log: self, type: type, a[0], a[1], a[2])
    case 2: os_log(f, log: self, type: type, a[0], a[1])
    case 1: os_log(f, log: self, type: type, a[0])
    default: os_log(f, log: self, type: type)
    }
  }
}
