import Foundation
import os

// MARK: - Application subsystem.

private let subsystem = Bundle.main.bundleIdentifier!

private func log(category: String) -> OSLog {
  return OSLog(subsystem: subsystem, category: category)
}

// MARK: - Application Loggers

enum Logger {
  static let networking = log(category: "Networking")
  static let persistence = log(category: "Persistence")
  static let auth = log(category: "Auth")
  static let transactions = log(category: "Transactions")
  static let transactionDetails = log(category: "TransactionDetails")
  static let mnemonic = log(category: "Mnemonic")
  static let notifications = log(category: "Notifications")
  static let security = log(category: "Security")
  static let home = log(category: "Home")
  static let pin = log(category: "Pin")
  static let firebase = log(category: "Firebase")
}
