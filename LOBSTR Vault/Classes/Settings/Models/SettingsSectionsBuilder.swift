import Foundation

protocol SettingsSectionsBuilder {
  func buildSections() -> [SettingsSection]
}

struct SettingsSectionsBuilderImpl: SettingsSectionsBuilder {
  func buildSections() -> [SettingsSection] {
    let wallet = SettingsSection(type: .account, rows: [.publicKey])
    
    let securityRows: [SettingsRow] = [.mnemonicCode, .biometricId, .changePin]
    
    let security = SettingsSection(type: .security,
                                   rows: securityRows)
    
    let about = SettingsSection(type: .about, rows: [.version, .help])
    return [wallet, security, about]
  }
}