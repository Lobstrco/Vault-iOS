import Foundation
import stellarsdk
import UIKit

class SettingsPresenterImpl: SettingsPresenter {
  private weak var view: SettingsView?
  
  private lazy var sections: [SettingsSection] =
    self.settingsSectionsBuilder.buildSections()
  
  private let mnemonicManager: MnemonicManager
  private var biometricAuthManager: BiometricAuthManager
  private let settingsSectionsBuilder: SettingsSectionsBuilder
  
  private let navigationController: UINavigationController
  
  private let notificationRegistrator: NotificationManager
  
  // MARK: - Init
  
  init(view: SettingsView,
       navigationController: UINavigationController,
       mnemonicManager: MnemonicManager = MnemonicManagerImpl(),
       biometricAuthManager: BiometricAuthManager = BiometricAuthManagerImpl(),
       notificationRegistrator: NotificationManager = NotificationManager(),
       settingsSectionsBuilder: SettingsSectionsBuilder = SettingsSectionsBuilderImpl()) {
    self.view = view
    self.navigationController = navigationController
    self.mnemonicManager = mnemonicManager
    self.biometricAuthManager = biometricAuthManager
    self.settingsSectionsBuilder = settingsSectionsBuilder
    self.notificationRegistrator = notificationRegistrator
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
  func configure(biometricIDCell: BiometricIDTableViewCell, type: SwitchType) {
    biometricIDCell.switchType = type
    biometricIDCell.delegate = self
    
    switch type {
    case .biometricID:
      biometricIDCell.setTitle(Device.biometricType.name)
      biometricIDCell.setSwitch(biometricAuthManager.isBiometricAuthEnabled)
    case .notifications:
      biometricIDCell.setTitle(L10n.textSettingsNotificationsField)
      biometricIDCell.setSwitch(ApplicationCoordinatorHelper.isNotificationsEnabled)
    }
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
      let title = L10n.textSettingsSignersField
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
      disclosureIndicatorTableViewCell.setTextColor(Asset.Colors.red.color)
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
    case .publicKey:
      showPublicKeyButtonWasPressed()
    case .signerForAccounts:
      transitionToSignerDetails()
    case .changePin:
      transitionToChangePin()
    case .mnemonicCode:
      transitionToMnemonicCode()
    case .logout:
      logoutButtonWasPressed()
    case .help:
      transitionToHelp()
    default:
      break
    }
  }
}

// MARK: - BiometricIDTableViewCellDelegate

extension SettingsPresenterImpl {
  func biometricIDSwitchValueChanged(_ value: Bool, type: SwitchType) {
    switch type {
    case .notifications:
      ApplicationCoordinatorHelper.isNotificationsEnabled = !ApplicationCoordinatorHelper.isNotificationsEnabled
      if ApplicationCoordinatorHelper.isNotificationsEnabled {
        notificationRegistrator.register()
      } else {
        notificationRegistrator.unregister()
      }
      
      view?.setSettings()
    case .biometricID:
      biometricAuthManager.isBiometricAuthEnabled = value
      
      guard biometricAuthManager.isBiometricAuthEnabled == true
      else { return }
      
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
}

extension SettingsPresenterImpl {
  func showPublicKeyButtonWasPressed() {
    let publicKeyView = Bundle.main.loadNibNamed("PublicKeyPopover",
                                                 owner: view,
                                                 options: nil)?.first as! PublicKeyPopover
    publicKeyView.initData()
    
    let popoverHeight: CGFloat = 214
    let popover = CustomPopoverViewController(height: popoverHeight, view: publicKeyView)
    publicKeyView.popoverDelegate = popover
    
    view?.setPublicKeyPopover(popover)
  }
}

// MARK: - Logout

extension SettingsPresenterImpl {
  func logoutButtonWasPressed() {
    view?.setLogoutAlert()
  }
  
  func logoutOperationWasConfirmed() {
    ApplicationCoordinatorHelper.logout()
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
    
    navigationController.pushViewController(signerDetailsTableViewController,
                                            animated: true)
  }
  
  func transitionToMnemonicCode() {
    let pinViewController = PinViewController.createFromStoryboard()
    
    pinViewController.mode = .enterPinForMnemonicPhrase
    pinViewController.completion = {
      pinViewController.dismiss(animated: true, completion: nil)
      let mnemonicGenerationViewController = MnemonicGenerationViewController.createFromStoryboard()
      mnemonicGenerationViewController.presenter = MnemonicGenerationPresenterImpl(view: mnemonicGenerationViewController,
                                                                                   mnemonicMode: .showMnemonic)
      self.navigationController.pushViewController(mnemonicGenerationViewController,
                                              animated: true)
    }
    
    let pinNavigationController = UINavigationController(rootViewController: pinViewController)
    navigationController.present(pinNavigationController, animated: true, completion: nil)
  }
  
  func transitionToHelp() {
    let helpViewController = HelpViewController.createFromStoryboard()
    
    let settingsViewController = view as! SettingsViewController
    settingsViewController.navigationController?.pushViewController(helpViewController, animated: true)
  }
}
