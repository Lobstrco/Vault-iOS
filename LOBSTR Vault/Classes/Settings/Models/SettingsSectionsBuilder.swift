import Foundation

protocol SettingsSectionsBuilder {
  func buildSections() -> [SettingsSection]
}

struct SettingsSectionsBuilderImpl: SettingsSectionsBuilder {
  func buildSections() -> [SettingsSection] {
    let wallet = SettingsSection(type: .account, rows: [.publicKey, .signerForAccounts])
    
    let securityRows: [SettingsRow] = [.mnemonicCode, .changePin, .biometricId]
    
    let security = SettingsSection(type: .security,
                                   rows: securityRows)
    
    let about = SettingsSection(type: .about, rows: [.help, .notifications, .promptTransactionDecisions, .rateUs, .licenses, .version,  .logout, .copyright])
    return [wallet, security, about]
  }
}
