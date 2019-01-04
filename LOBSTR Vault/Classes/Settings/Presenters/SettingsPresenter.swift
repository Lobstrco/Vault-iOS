import Foundation

typealias SettingsPresenter =
  SettingsLifeCycle &
  SettingsDataSource &
  SettingsCellConfigurator &
  SettingsDelegate

protocol SettingsLifeCycle {
  func settingsViewDidLoad()
}

protocol SettingsDataSource {
  func numberOfSections() -> Int
  func numberOfRows(in section: Int) -> Int

  func row(for indexPath: IndexPath) -> SettingsRow
  func title(for section: Int) -> String
}

protocol SettingsDelegate {
  func settingsRowWasSelected(at indexPath: IndexPath)
}

protocol SettingsCellConfigurator {
  func configure(publicKeyCell: PublicKeyTableViewCell)
  func configure(biometricIdCell: BiometricIdTableViewCell)
  func configure(rightDetailCell: RightDetailTableViewCell,
                 row: SettingsRow)
  func configure(disclosureIndicatorTableViewCell: DisclosureIndicatorTableViewCell,
                 row: SettingsRow)
}

