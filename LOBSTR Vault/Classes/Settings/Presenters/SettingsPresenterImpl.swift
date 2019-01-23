import Foundation
import stellarsdk

class SettingsPresenterImpl: SettingsPresenter {
  private weak var view: SettingsView?
  
  private lazy var sections: [SettingsSection] =
    self.settingsSectionsBuilder.buildSections()
  
  private let mnemonicManager: MnemonicManager
  private var biometricAuthManager: BiometricAuthManager
  private let settingsSectionsBuilder: SettingsSectionsBuilder
  private let vaultStorage: VaultStorage
  
  private let navigationController: UINavigationController
  
  // MARK: - Init
  
  init(view: SettingsView,
       navigationController: UINavigationController,
       mnemonicManager: MnemonicManager = MnemonicManagerImpl(),
       biometricAuthManager: BiometricAuthManager = BiometricAuthManagerImpl(),
       settingsSectionsBuilder: SettingsSectionsBuilder = SettingsSectionsBuilderImpl(),
       vaultStorage: VaultStorage = VaultStorage()) {
    self.view = view
    self.navigationController = navigationController
    self.mnemonicManager = mnemonicManager
    self.biometricAuthManager = biometricAuthManager
    self.settingsSectionsBuilder = settingsSectionsBuilder
    self.vaultStorage = vaultStorage
  }
}

// MARK: - SettingsLifecycle

extension SettingsPresenterImpl {
  func settingsViewDidLoad() {
    view?.setSettings()
  }
}

// MARK: - SettingsDataSource

extension SettingsPresenterImpl {
  func numberOfSections() -> Int {
    return sections.count
  }
  
  func numberOfRows(in section: Int) -> Int {
    return sections[section].rows.count
  }
  
  func row(for indexPath: IndexPath) -> SettingsRow {
    let section = sections[indexPath.section]
    let row = section.rows[indexPath.row]
    return row
  }
  
  func title(for section: Int) -> String {
    let section = sections[section]
    return section.type.title
  }
}

// MARK: - SettingsCellConfigurator

extension SettingsPresenterImpl {
  func configure(publicKeyCell: PublicKeyTableViewCell) {
    
    guard let publicKey = vaultStorage.getPublicKeyFromKeychain()
    else { return }

    publicKeyCell.setPublicKey(publicKey)
  }
  
  func configure(biometricIDCell: BiometricIDTableViewCell) {
    biometricIDCell.setTitle(Device.biometricType.name)
    biometricIDCell.setSwitch(biometricAuthManager.isBiometricAuthEnabled)
    biometricIDCell.delegate = self
  }
  
  func configure(rightDetailCell: RightDetailTableViewCell,
                 row: SettingsRow) {
    switch row {
    case .version:
      let title = "Version"
      let version = ApplicationInfo.version
      rightDetailCell.setTitle(title, detail: version)
    default:
      break
    }
  }
  
  func configure(disclosureIndicatorTableViewCell: DisclosureIndicatorTableViewCell,
                 row: SettingsRow) {
    switch row {
    case .mnemonicCode:
      let title = "Mnemonic Code"
      disclosureIndicatorTableViewCell.setTitle(title)
    case .changePin:
      let title = "Change PIN"
      disclosureIndicatorTableViewCell.setTitle(title)
    case .help:
      let title = "Help"
      disclosureIndicatorTableViewCell.setTitle(title)
    default:
      break
    }
  }
}

// MARK: - SettingsDelegate

extension SettingsPresenterImpl {
  func settingsRowWasSelected(at indexPath: IndexPath) {
    let selectedRow = row(for: indexPath)
    
    switch selectedRow {
    case .changePin:
      showChangePin()
    default:
      break
    }
  }
}

// MARK: - BiometricIDTableViewCellDelegate

extension SettingsPresenterImpl {
  func biometricIDSwitchValueChanged(_ value: Bool) {
    
    self.biometricAuthManager.isBiometricAuthEnabled = value
    
    guard self.biometricAuthManager.isBiometricAuthEnabled == true
    else {return }

    biometricAuthManager.authenticateUser { [weak self] result in
      switch result {
      case .success:
        self?.view?.setSettings()
      case .failure(let error):
        guard let error = error as? VaultError.BiometricError else { return }
        self?.biometricAuthManager.isBiometricAuthEnabled = false
        self?.view?.setErrorAlert(for: error)
        self?.view?.setSettings()
      }
    }
    
  }
}

// MARK: -  Navigation

extension SettingsPresenterImpl {
  func showChangePin() {
    let pinViewController = PinViewController.createFromStoryboard()    
    
    pinViewController.hidesBottomBarWhenPushed = true
    pinViewController.mode = .changePin
    
    navigationController.pushViewController(pinViewController, animated: true)
  }
}
