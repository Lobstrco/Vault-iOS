import AcknowList
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
  
  private let notificationManager: NotificationManager
  
  // MARK: - Init
  
  init(view: SettingsView,
       navigationController: UINavigationController,
       mnemonicManager: MnemonicManager = MnemonicManagerImpl(),
       biometricAuthManager: BiometricAuthManager = BiometricAuthManagerImpl(),
       notificationManager: NotificationManager = NotificationManager(),
       settingsSectionsBuilder: SettingsSectionsBuilder = SettingsSectionsBuilderImpl()) {
    self.view = view
    self.navigationController = navigationController
    self.mnemonicManager = mnemonicManager
    self.biometricAuthManager = biometricAuthManager
    self.settingsSectionsBuilder = settingsSectionsBuilder
    self.notificationManager = notificationManager
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
  func configure(switchCell: SwitchTableViewCell, type: SwitchType) {
    switchCell.switchType = type
    switchCell.delegate = self
    
    switch type {
    case .biometricID:
      switchCell.setTitle(Device.biometricType.name)
      switchCell.setSwitch(biometricAuthManager.isBiometricAuthEnabled)
    case .notifications:
      switchCell.setTitle(L10n.textSettingsNotificationsField)
      switchCell.setSwitch(UserDefaultsHelper.isNotificationsEnabled)
    case .promptTransactionDecisions:
      switchCell.setTitle(L10n.textSettingsPromtDecisionsField)
      switchCell.setSwitch(UserDefaultsHelper.isPromtTransactionDecisionsEnabled)
    }
  }
  
  func configure(rightDetailCell: RightDetailTableViewCell,
                 row: SettingsRow) {
    switch row {
    case .version:
      var title = L10n.textSettingsVersionField
      if Constants.baseURL.contains("staging") {
        title += " (staging)"
      }
      
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
      disclosureIndicatorTableViewCell.setAttribute(getSignerForAccountsData().attribute)
      disclosureIndicatorTableViewCell.setTitle(getSignerForAccountsData().title)
    case .mnemonicCode:
      disclosureIndicatorTableViewCell.setTitle(L10n.textSettingsMnemonicField)
    case .changePin:
      disclosureIndicatorTableViewCell.setTitle(L10n.textSettingsChangePinField)
    case .help:
      disclosureIndicatorTableViewCell.setTitle(L10n.textSettingsHelpField)
    case .logout:
      disclosureIndicatorTableViewCell.setTitle(L10n.textSettingsLogoutfield)
      disclosureIndicatorTableViewCell.setTextColor(Asset.Colors.red.color)
    case .licenses:
      disclosureIndicatorTableViewCell.setTitle(L10n.navTitleLicenses)
    case .rateUs:
      disclosureIndicatorTableViewCell.setTitle(L10n.textSettingsRateUsField)
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
    case .licenses:
      transitionToLicenses()
    case .rateUs:
      transitionToMarket()
    default:
      break
    }
  }
}

// MARK: - BiometricIDTableViewCellDelegate

extension SettingsPresenterImpl {
  func switchValueChanged(_ value: Bool, type: SwitchType) {
    switch type {
    case .notifications:
      
      notificationManager.requestAuthorization { isGranted in
        guard isGranted else {
          DispatchQueue.main.async {
            self.view?.setDisablePushNotificationAlert()
            self.view?.setSettings()
          }
          return
        }
        
        DispatchQueue.main.async {
          UserDefaultsHelper.isNotificationsEnabled = value
          if UserDefaultsHelper.isNotificationsEnabled {
            self.notificationManager.register()
          } else {
            self.notificationManager.unregister()
          }
          
          self.view?.setSettings()
        }
      }
      
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
    case .promptTransactionDecisions:
      UserDefaultsHelper.isPromtTransactionDecisionsEnabled = value
    }
  }
}

extension SettingsPresenterImpl {
  func showPublicKeyButtonWasPressed() {
    let publicKeyView = Bundle.main.loadNibNamed("PublicKeyPopover",
                                                 owner: view,
                                                 options: nil)?.first as! PublicKeyPopover
    publicKeyView.initData()
    
    let popoverHeight: CGFloat = 440
    let popover = CustomPopoverViewController(height: popoverHeight, view: publicKeyView)
    publicKeyView.popoverDelegate = popover
    
    view?.setPublicKeyPopover(popover)
  }
}

// MARK: -  Private

extension SettingsPresenterImpl {
  private func getSignerForAccountsData() -> (title: String,
                                              attribute: NSMutableAttributedString) {
    let positionOfNumberInTitle = 11
    var title = L10n.textSettingsSignersField.replacingOccurrences(of: "[number]",
                                                                   with: String(UserDefaultsHelper.numberOfSignerAccounts))
    let titleAttribute = NSMutableAttributedString(string: title)
    titleAttribute.addAttributes([.foregroundColor: Asset.Colors.main.color,
                                  .font: UIFont.boldSystemFont(ofSize: 20)],
                                 range: NSRange(location: positionOfNumberInTitle,
                                                length: 1))
    
    if UserDefaultsHelper.numberOfSignerAccounts > 1 {
      title.append("s")
    }
    
    return (title, titleAttribute)
  }
  
  private func addDescriptionLabel(to pinViewController: UIViewController) {
    let titleLabel = UILabel()
    titleLabel.text = L10n.textSettingsDisplayMnemonicTitle
    titleLabel.numberOfLines = 3
    titleLabel.textColor = Asset.Colors.grayOpacity70.color
    titleLabel.font = UIFont.systemFont(ofSize: 15)
    titleLabel.textAlignment = .center
    
    pinViewController.view.addSubview(titleLabel)
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.topAnchor.constraint(equalTo: pinViewController.view.topAnchor, constant: 100).isActive = true
    titleLabel.widthAnchor.constraint(equalToConstant: 315).isActive = true
    titleLabel.centerXAnchor.constraint(equalTo: pinViewController.view.centerXAnchor).isActive = true
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
    addDescriptionLabel(to: pinViewController)
    
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
  
  func transitionToLicenses() {
    let acknowListViewController = AcknowListViewController()
    let settingsViewController = view as! SettingsViewController
    settingsViewController.navigationController?.pushViewController(acknowListViewController, animated: true)
  }
  
  func transitionToMarket() {
    let appleID = "1452248529"
    let appStoreLink = "https://itunes.apple.com/app/id\(appleID)?action=write-review"
    UIApplication.shared.open(URL(string: appStoreLink)!, options: [:], completionHandler: nil)
  }
}
