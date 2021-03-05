import Foundation

protocol SettingsSectionsBuilder {
  func buildSections() -> [SettingsSection]
}

struct SettingsSectionsBuilderImpl: SettingsSectionsBuilder {
  func buildSections() -> [SettingsSection] {
        
    var accountRows: [SettingsRow] = [.publicKey, .signerForAccounts, .notifications]
    var securityRows: [SettingsRow] = []
    var otherRows: [SettingsRow] = []
    
    switch UserDefaultsHelper.accountStatus {
    case .createdByDefault:
      accountRows.append(.promptTransactionDecisions)
      securityRows.append(contentsOf: [.mnemonicCode, .changePin, .biometricId, .spamProtection])
      otherRows.append(contentsOf: [.buyCard, .rateUs, .licenses, .version,  .logout, .copyright])
    case .createdWithTangem:
      securityRows.append(.spamProtection)
      otherRows.append(contentsOf: [.rateUs, .licenses, .version,  .logout, .copyright])
    default:
      break
    }
    
    let account = SettingsSection(type: .account, rows: accountRows)
    let security = SettingsSection(type: .security, rows: securityRows)
    let other = SettingsSection(type: .other, rows: otherRows)
    let help = SettingsSection(type: .help, rows: [.help, .support])
                
    return [account, security, help, other]
  }
}
