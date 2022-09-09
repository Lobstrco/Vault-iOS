import Foundation

public struct SettingsSection {
  var type: SettingsSectionType
  var rows: [SettingsRow]
}

extension SettingsSection: Equatable {
  public static func == (lhs: SettingsSection, rhs: SettingsSection) -> Bool {
    return lhs.type == rhs.type && lhs.rows == rhs.rows
  }
}

public enum SettingsSectionType {
  case account
  case security
  case help
  case other
  
  var title: String {
    switch self {
    case .account:
      return L10n.textSettingsAccountSection
    case .security:
      return L10n.textSettingsSecuritySection
    case .help:
      return L10n.textSettingsHelpSection
    case .other:
      return L10n.textSettingsOtherSection
    }
  }
}

public enum SettingsRow {
  case publicKey
  case signerForAccounts
  case notifications
  case mnemonicCode
  case biometricId
  case changePin
  case version
  case help
  case logout
  case copyright
  case licenses
  case promptTransactionDecisions
  case rateUs
  case spamProtection
  case support
  case buyCard
  case manageNicknames
}

