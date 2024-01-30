import Foundation

typealias SettingsPresenter =
  SettingsLifecycle &
  SettingsDataSource &
  SettingsCellConfigurator &
  SettingsDelegate &
  SwitchTableViewCellDelegate &
  SettingsLogout

protocol SettingsLifecycle {
  func settingsViewDidLoad()
  func settingsViewDidAppear()
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
  func configure(switchCell: SwitchTableViewCell, type: SwitchType)
  func configure(rightDetailCell: RightDetailTableViewCell,
                 row: SettingsRow)
  func configure(disclosureIndicatorTableViewCell: DisclosureIndicatorTableViewCell,
                 row: SettingsRow)
  func configure(rightActionCell: PublicKeyTableViewCell,
                 row: SettingsRow)
}

protocol SettingsLogout {
  func logoutButtonWasPressed()
  func logoutOperationWasConfirmed()
  func syncButtonWasPressed()
}

