import AcknowList
import Foundation
import stellarsdk
import UIKit
import PKHUD

class SettingsPresenterImpl: SettingsPresenter {
  private weak var view: SettingsView?

  private lazy var sections: [SettingsSection] =
    self.settingsSectionsBuilder.buildSections()

  private let mnemonicManager: MnemonicManager
  private var biometricAuthManager: BiometricAuthManager
  private let settingsSectionsBuilder: SettingsSectionsBuilder

  private weak var navigationController: UINavigationController?

  private let notificationManager: NotificationManager

  private var spamProtectionEnabled = false

  // MARK: - Init

  init(view: SettingsView,
       navigationController: UINavigationController?,
       mnemonicManager: MnemonicManager = MnemonicManagerImpl(),
       biometricAuthManager: BiometricAuthManager = BiometricAuthManagerImpl(),
       notificationManager: NotificationManager = NotificationManager(),
       settingsSectionsBuilder: SettingsSectionsBuilder = SettingsSectionsBuilderImpl())
  {
    self.view = view
    self.navigationController = navigationController
    self.mnemonicManager = mnemonicManager
    self.biometricAuthManager = biometricAuthManager
    self.settingsSectionsBuilder = settingsSectionsBuilder
    self.notificationManager = notificationManager
    
    addObservers()
  }
  
  @objc func onDidCloudRecordsGet(_ notification: Notification) {
    DispatchQueue.main.async {
      HUD.hide()
    }
  }
    
  @objc func showICloudStatusIsNotAvaliableAlert(_ notification: Notification) {
    DispatchQueue.main.async {
      UserDefaultsHelper.isICloudSynchronizationEnabled = false
      self.reloadSections()
      HUD.hide()
    }
  }
}

// MARK: - SettingsLifecycle

extension SettingsPresenterImpl {
  func settingsViewDidLoad() {
    UtilityHelper.checkAllJWTTokens()
    view?.setSettings()
  }

  func settingsViewDidAppear() {
    reloadSections()
    guard let viewController = view as? UIViewController else { return }
    guard UtilityHelper.isTokenUpdated(view: viewController) else { return }

    PromtForTransactionDecisionsHelper.setPromtForTransactionDecisionsStatusesDefaultValues()

    setSpamProtectionSwitch()
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

      // Multiaccount support case
      if !UserDefaultsHelper.pushNotificationsStatuses.isEmpty {
        switchCell.setSwitch(NotificationsStatusesHelper.isNotificationsEnabled)
      } else {
        switchCell.setSwitch(UserDefaultsHelper.isNotificationsEnabled)
      }
    }
  }

  func configure(rightDetailCell: RightDetailTableViewCell,
                 row: SettingsRow)
  {
    switch row {
    case .version:
      var title = L10n.textSettingsVersionField
      if Environment.environmentType == .staging {
        title += " (staging)"
      }

      let version = ApplicationInfo.version
      rightDetailCell.setTitle(title, detail: version)
    default:
      break
    }
  }

  func configure(disclosureIndicatorTableViewCell: DisclosureIndicatorTableViewCell,
                 row: SettingsRow)
  {
    disclosureIndicatorTableViewCell.setTextColor(Asset.Colors.black.color)
    switch row {
    case .signerForAccounts:
      disclosureIndicatorTableViewCell.setAttribute(getSignerForAccountsData().attribute)
      disclosureIndicatorTableViewCell.setTextStatus("")
    case .mnemonicCode:
      disclosureIndicatorTableViewCell.setTitle(L10n.textSettingsMnemonicField)
      disclosureIndicatorTableViewCell.setTextStatus("")
    case .changePin:
      disclosureIndicatorTableViewCell.setTitle(L10n.textSettingsChangePinField)
      disclosureIndicatorTableViewCell.setTextStatus("")
    case .help:
      disclosureIndicatorTableViewCell.setTitle(L10n.textSettingsHelpField)
      disclosureIndicatorTableViewCell.setTextStatus("")
    case .logout:
      disclosureIndicatorTableViewCell.setTitle(L10n.textSettingsLogoutfield)
      disclosureIndicatorTableViewCell.setTextColor(Asset.Colors.red.color)
      disclosureIndicatorTableViewCell.setTextStatus("")
    case .licenses:
      disclosureIndicatorTableViewCell.setTitle(L10n.navTitleLicenses)
      disclosureIndicatorTableViewCell.setTextStatus("")
    case .rateUs:
      disclosureIndicatorTableViewCell.setTitle(L10n.textSettingsRateUsField)
      disclosureIndicatorTableViewCell.setTextStatus("")
    case .buyCard:
      disclosureIndicatorTableViewCell.setTitle("Learn About the Signer Card")
      disclosureIndicatorTableViewCell.setTextStatus("")
    case .support:
      disclosureIndicatorTableViewCell.setTitle("Contact Support")
      disclosureIndicatorTableViewCell.setTextStatus("")
    case .promptTransactionDecisions:
      disclosureIndicatorTableViewCell.setTitle(L10n.textSettingsPromtDecisionsField)
      let isPromtTransactionDecisionsEnabled = PromtForTransactionDecisionsHelper.isPromtTransactionDecisionsEnabled
      let statusText = isPromtTransactionDecisionsEnabled ? "Yes" : "No"
      disclosureIndicatorTableViewCell.setTextStatus(statusText)
    case .spamProtection:
      disclosureIndicatorTableViewCell.setTitle(L10n.textSettingsSpamProtectionField)
      let statusText = !spamProtectionEnabled ? "Yes" : "No"
      disclosureIndicatorTableViewCell.setTextStatus(statusText)
    case .manageNicknames:
      disclosureIndicatorTableViewCell.setTitle(L10n.textSettingsManageNicknames)
      disclosureIndicatorTableViewCell.setTextStatus("")
    case .iCloudSync:
      disclosureIndicatorTableViewCell.setTitle(L10n.textSettingsICloudSync)
      let statusText = UserDefaultsHelper.isICloudSynchronizationEnabled ? "Yes" : "No"
      disclosureIndicatorTableViewCell.setTextStatus(statusText)
    default:
      break
    }
  }
  
  func configure(rightActionCell: PublicKeyTableViewCell,
                 row: SettingsRow)
  {
    
    switch row {
    case .publicKey:
      rightActionCell.configure(L10n.textSettingsPublicKeyTitle, L10n.buttonTitleShow)
    case .updateNicknames:
      rightActionCell.configure(L10n.textSettingsGetLatestNicknamesTitle, L10n.buttonTitleSync)
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
    case .buyCard:
      UtilityHelper.openTangemVaultLanding()
    case .support:
      contactSupport()
    case .promptTransactionDecisions:
      transitionToTransactionConfirmation()
    case .spamProtection:
      transitionToSpamProtection()
    case .manageNicknames:
      transitionToManageNicknames()
    case .iCloudSync:
      transitionToICloudSync()
    case .updateNicknames:
      syncICloudNicknamesButtonWasPressed()
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
          // Multiaccount support case
          if !UserDefaultsHelper.pushNotificationsStatuses.isEmpty {
            UserDefaultsHelper.pushNotificationsStatuses[UserDefaultsHelper.activePublicKey] = value
            if value {
              self.notificationManager.register(allAccounts: false)
            } else {
              self.notificationManager.unregister(allAccounts: false)
            }
            self.view?.setSettings()
          } else {
            UserDefaultsHelper.isNotificationsEnabled = value
            if UserDefaultsHelper.isNotificationsEnabled {
              self.notificationManager.register()
            } else {
              self.notificationManager.unregister()
            }
            self.view?.setSettings()
          }
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
        case let .failure(error):
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
    let publicKeyView = Bundle.main.loadNibNamed(PublicKeyPopover.nibName,
                                                 owner: view,
                                                 options: nil)?.first as! PublicKeyPopover
    publicKeyView.initData()

    let popoverHeight: CGFloat = UIScreen.main.bounds.height / 2.2
    let popover = CustomPopoverViewController(height: popoverHeight, view: publicKeyView)
    publicKeyView.popoverDelegate = popover

    view?.setPublicKeyPopover(popover)
  }
  
  func syncICloudNicknamesButtonWasPressed() {
    guard UIDevice.isConnectedToNetwork else {
      view?.showNoInternetConnectionAlert()
      return
    }
    if !UserDefaultsHelper.isICloudSynchronizationActive {
      view?.setGetLatestNicknamesAlert()
    } else {
      view?.setICloudSyncIsActiveAlert()
    }
  }
}

// MARK: -  Private

private extension SettingsPresenterImpl {
  func reloadSections() {
    sections = settingsSectionsBuilder.buildSections()
    view?.setSettings()
  }
  
  func contactSupport() {
    let bodyEmail = UtilityHelper.createBodyEmail()
    if let emailUrl = UtilityHelper.createEmailUrl(to: Constants.recipientEmail, subject: Constants.subjectEmail, body: bodyEmail) {
      UIApplication.shared.open(emailUrl)
    }
  }

  func getSignerForAccountsData() -> (title: String,
                                      attribute: NSMutableAttributedString)
  {
    let positionOfNumberInTitle = 9
    var length = 0
    var title = L10n.textSettingsSignersField.replacingOccurrences(of: "[number]",
                                                                   with: String(UserDefaultsHelper.numberOfSignerAccounts))

    if UserDefaultsHelper.numberOfSignerAccounts == 0 ||
      UserDefaultsHelper.numberOfSignerAccounts > 1
    {
      title.append("s")
    }

    for symbol in title {
      if symbol.isNumber {
        length += 1
      }
    }

    let titleAttribute = NSMutableAttributedString(string: title)
    titleAttribute.addAttributes([.foregroundColor: Asset.Colors.main.color,
                                  .font: UIFont.boldSystemFont(ofSize: 20)],
                                 range: NSRange(location: positionOfNumberInTitle,
                                                length: length))
    return (title, titleAttribute)
  }

  func addDescriptionLabel(to pinViewController: UIViewController) {
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

  func setSpamProtectionSwitch() {
    let apiLoader = APIRequestLoader<AccountConfigRequest>(apiRequest: AccountConfigRequest())
    apiLoader.loadAPIRequest(requestData: nil) { result in
      switch result {
      case let .success(accountConfig):
        guard let protectionEnabled = accountConfig.spamProtectionEnabled else { return }
        self.spamProtectionEnabled = protectionEnabled
        self.view?.setSettings()
      case let .failure(error):
        Logger.security.error("Couldn't get spam protection data with error: \(error)")
      }
    }
  }
  
  func addObservers() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidCloudRecordsGet(_:)),
                                           name: .didCloudRecordsGet,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(showICloudStatusIsNotAvaliableAlert(_:)),
                                           name: .iCloudStatusIsNotAvaliable,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidCloudRecordsGet(_:)),
                                           name: .didCloudRecordsGetError,
                                           object: nil)
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
  
  func syncButtonWasPressed() {
    DispatchQueue.main.async {
      HUD.show(.labeledProgress(title: nil, subtitle: L10n.animationWaiting))
    }
    CloudKitNicknameHelper.getAllRecords()
  }
}

// MARK: -  Navigation

extension SettingsPresenterImpl {
  func transitionToTransactionConfirmation() {
    let transactionConfirmationViewController = SettingsSelectionViewController.createFromStoryboard()
    transactionConfirmationViewController.screenType = .promptTransactionDecisions

    navigationController?.pushViewController(transactionConfirmationViewController,
                                             animated: true)
  }

  func transitionToSpamProtection() {
    let transactionConfirmationViewController = SettingsSelectionViewController.createFromStoryboard()
    transactionConfirmationViewController.screenType = .spamProtection
    transactionConfirmationViewController.spamProtectionEnabled = spamProtectionEnabled
    transactionConfirmationViewController.delegate = self

    navigationController?.pushViewController(transactionConfirmationViewController,
                                             animated: true)
  }
  
  func transitionToICloudSync() {
    let transactionConfirmationViewController = SettingsSelectionViewController.createFromStoryboard()
    transactionConfirmationViewController.screenType = .iCloudSync
    
    navigationController?.pushViewController(transactionConfirmationViewController, animated: true)
  }
  
  func transitionToChangePin() {
    let pinViewController = PinViewController.createFromStoryboard()

    pinViewController.hidesBottomBarWhenPushed = true
    pinViewController.mode = .changePin

    navigationController?.pushViewController(pinViewController,
                                             animated: true)
  }

  func transitionToSignerDetails() {
    let signerDetailsViewController = SignerDetailsViewController.createFromStoryboard()
    signerDetailsViewController.screenType = .protectedAccounts
    navigationController?.pushViewController(signerDetailsViewController,
                                             animated: true)
  }

  func transitionToMnemonicCode() {
    let pinViewController = PinViewController.createFromStoryboard()

    pinViewController.mode = .enterPinForMnemonicPhrase
    addDescriptionLabel(to: pinViewController)

    pinViewController.completion = {
      pinViewController.dismiss(animated: true, completion: nil)
      let mnemonicGenerationViewController = MnemonicGenerationViewController.createFromStoryboard()
      mnemonicGenerationViewController.presenter =
      MnemonicGenerationPresenterImpl(view: mnemonicGenerationViewController,
                                      mnemonicMode: .showMnemonic)
      self.navigationController?.pushViewController(mnemonicGenerationViewController,
                                               animated: true)
    }

    let pinNavigationController = UINavigationController(rootViewController: pinViewController)
    navigationController?.present(pinNavigationController,
                                 animated: true,
                                 completion: nil)
  }

  func transitionToHelp() {
    let settingsViewController = view as! SettingsViewController
    let helpViewController = FreshDeskHelper.getHelpCenterController()
    settingsViewController.navigationController?.present(helpViewController, animated: true)
  }

  func transitionToLicenses() {
    let acknowListViewController = AcknowListViewController(fileNamed: "Pods-LOBSTR Vault-acknowledgements")
    let settingsViewController = view as! SettingsViewController
    settingsViewController.navigationController?.pushViewController(acknowListViewController, animated: true)
  }

  func transitionToMarket() {
    UIApplication.shared.open(URL(string: Constants.appStoreLinkWithReviewAction)!, options: [:], completionHandler: nil)
  }

  func transitionToManageNicknames() {
    let signerDetailsViewController = SignerDetailsViewController.createFromStoryboard()
    signerDetailsViewController.screenType = .manageNicknames
    navigationController?.pushViewController(signerDetailsViewController,
                                            animated: true)
  }
}

extension SettingsPresenterImpl: SettingsSelectionViewControllerDelegate {
  func updateSpamProtection(_ value: Bool?) {
    guard let value = value else { return }
    spamProtectionEnabled = value
    let accountConfigParameters = AccountConfigParameters(spamProtectionEnabled: spamProtectionEnabled)
    let apiLoader = APIRequestLoader<ChangeAccountConfigRequest>(apiRequest: ChangeAccountConfigRequest())
    apiLoader.loadAPIRequest(requestData: accountConfigParameters) { result in
      switch result {
      case let .success(accountConfig):
        guard let protectionEnabled = accountConfig.spamProtectionEnabled else { return }
        self.spamProtectionEnabled = protectionEnabled
      case let .failure(error):
        Logger.security.error("Couldn't get spam protection data with error: \(error)")
      }
    }
  }
}
