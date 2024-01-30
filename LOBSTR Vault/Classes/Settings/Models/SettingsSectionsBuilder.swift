import Foundation

protocol SettingsSectionsBuilder {
  func buildSections() -> [SettingsSection]
}

struct SettingsSectionsBuilderImpl: SettingsSectionsBuilder {
  func buildSections() -> [SettingsSection] {
        
    var accountRows: [SettingsRow] = [.publicKey, .signerForAccounts, .notifications]
    var securityRows: [SettingsRow] = []
    var otherRows: [SettingsRow] = []
    var nicknamesRows: [SettingsRow] = []
    
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
    
    if UserDefaultsHelper.isICloudSynchronizationEnabled {
      nicknamesRows.append(contentsOf: [.manageNicknames, .iCloudSync, .updateNicknames])
    } else {
      nicknamesRows.append(contentsOf: [.manageNicknames, .iCloudSync])
    }
    
    let account = SettingsSection(type: .account, rows: accountRows)
    let nicknames = SettingsSection(type: .nicknames, rows: nicknamesRows)
    let security = SettingsSection(type: .security, rows: securityRows)
    let other = SettingsSection(type: .other, rows: otherRows)
    let help = SettingsSection(type: .help, rows: [.help, .support])
                
    return [account, nicknames, security, help, other]
  }
}
