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
      return "Account"
    case .security:
      return "Security"
    case .about:
      return "About"
    }
  }
}

public enum SettingsRow {
  case publicKey
  case mnemonicCode
  case biometricId
  case changePin
  case version
  case help
}

