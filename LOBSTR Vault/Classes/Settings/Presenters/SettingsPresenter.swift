import Foundation

typealias SettingsPresenter =
  SettingsLifecycle &
  SettingsDataSource &
  SettingsCellConfigurator &
  SettingsDelegate &
  BiometricIDTableViewCellDelegate &
  SettingsLogout

protocol SettingsLifecycle {
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
  func configure(biometricIDCell: BiometricIDTableViewCell, type: SwitchType)
  func configure(rightDetailCell: RightDetailTableViewCell,
                 row: SettingsRow)
  func configure(disclosureIndicatorTableViewCell: DisclosureIndicatorTableViewCell,
                 row: SettingsRow)
}

protocol SettingsLogout {
  func logoutButtonWasPressed()
  func logoutOperationWasConfirmed()
}

