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
      let title = L10n.textSettingsVersionField
      let version = ApplicationInfo.version
      rightDetailCell.setTitle(title, detail: version)
    default:
      break
    }
  }
  
  func configure(disclosureIndicatorTableViewCell: DisclosureIndicatorTableViewCell,
                 row: SettingsRow) {
    switch row {
    case .signerForAccounts:
      let title = "Signer for accounts"
      disclosureIndicatorTableViewCell.setTitle(title)
    case .mnemonicCode:
      let title = L10n.textSettingsMnemonicField
      disclosureIndicatorTableViewCell.setTitle(title)
    case .changePin:
      let title = L10n.textSettingsChangePinField
      disclosureIndicatorTableViewCell.setTitle(title)
    case .help:
      let title = L10n.textSettingsHelpField
      disclosureIndicatorTableViewCell.setTitle(title)
    case .logout:
      let title = L10n.textSettingsLogoutfield
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
    case .signerForAccounts:
      transitionToSignerDetails()
    case .changePin:
      transitionToChangePin()
    case .mnemonicCode:
      transitionToMnemonicCode()
    case .logout:
      logout()
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
  func transitionToChangePin() {
    let pinViewController = PinViewController.createFromStoryboard()    
    
    pinViewController.hidesBottomBarWhenPushed = true
    pinViewController.mode = .changePin
    
    navigationController.pushViewController(pinViewController, animated: true)
  }
  
  func transitionToSignerDetails() {
    let signerDetailsTableViewController = SignerDetailsTableViewController.createFromStoryboard()
    
    let settingsViewController = view as! SettingsViewController
    settingsViewController.navigationController?.pushViewController(signerDetailsTableViewController, animated: true)
  }
  
  func transitionToMnemonicCode() {
    let mnemonicGenerationViewController = MnemonicGenerationViewController.createFromStoryboard()
    mnemonicGenerationViewController.presenter = MnemonicGenerationPresenterImpl(view: mnemonicGenerationViewController,
                                                                                 mnemonicMode: .showMnemonic)
    navigationController.pushViewController(mnemonicGenerationViewController, animated: true)
  }
  
  // temp
  func logout() {
    func clearKeychain() {
      let secItemClasses = [kSecClassGenericPassword,
                            kSecClassInternetPassword,
                            kSecClassCertificate,
                            kSecClassKey,
                            kSecClassIdentity]
      for secItemClass in secItemClasses {
        let dictionary = [kSecClass as String: secItemClass]
        SecItemDelete(dictionary as CFDictionary)
      }
    }
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
      else { return }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      appDelegate.applicationCoordinator.showMenuScreen()
    }
  }
}
