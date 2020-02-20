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
  case about
  
  var title: String {
    switch self {
    case .account:
      return L10n.textSettingsAccountSection
    case .security:
      return L10n.textSettingsSecuritySection
    case .about:
      return L10n.textSettingsAboutSection
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
}

