import UIKit
import PKHUD

protocol SettingsView: AnyObject {
  func setSettings()
  func setDisablePushNotificationAlert()
  func setErrorAlert(for error: Error)
  func setLogoutAlert()
  func setPublicKeyPopover(_ popover: CustomPopoverViewController)
  func setReloadSection()
}

class SettingsViewController: UIViewController,
  UITableViewDelegate, UITableViewDataSource, StoryboardCreation {
  
  static var storyboardType: Storyboards = .settings
  
  @IBOutlet var tableView: UITableView!
  
  var presenter: SettingsPresenter!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setAppearance()
    presenter = SettingsPresenterImpl(view: self,
                                      navigationController: navigationController)
    
    presenter.settingsViewDidLoad()    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presenter.settingsViewDidAppear()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = false
    navigationController?.setStatusBar(backgroundColor: Asset.Colors.background.color)
    navigationController?.navigationBar.barTintColor = Asset.Colors.background.color
  }
  
  // MARK: - Private
  
  func setAppearance() {
    navigationItem.title = L10n.navTitleSettings
  }
  
  func showHUDOfSuccessOfChangingPin() {
    PKHUD.sharedHUD.contentView = PKHUDSuccessViewCustom(title: nil, subtitle: L10n.textSettingsDisplayPinChanged)
    PKHUD.sharedHUD.show()
    PKHUD.sharedHUD.hide(afterDelay: 1.0)
  }
  
  // MARK: - UITableViewDelegate
  
  func tableView(_ tableView: UITableView,
                 didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    presenter.settingsRowWasSelected(at: indexPath)
  }
  
  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat {
    let row = presenter.row(for: indexPath)
    
    switch row {
    case .copyright:
      return 90
    default:
      return UITableViewCell.defaultHeight
    }
  }
  
  // MARK: - UITableViewDataSource
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return presenter.numberOfSections()
  }
  
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return presenter.numberOfRows(in: section)
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = presenter.row(for: indexPath)
    
    switch row {
    case .publicKey:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
        as PublicKeyTableViewCell
      return cell
    case .signerForAccounts:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
          as DisclosureIndicatorTableViewCell
      presenter.configure(disclosureIndicatorTableViewCell: cell,
                          row: row)
      return cell
    case .notifications:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
          as SwitchTableViewCell
      presenter.configure(switchCell: cell, type: .notifications)
      return cell
    case .mnemonicCode:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
          as DisclosureIndicatorTableViewCell
      presenter.configure(disclosureIndicatorTableViewCell: cell,
                          row: row)
      return cell
    case .biometricId:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
          as SwitchTableViewCell
      presenter.configure(switchCell: cell, type: .biometricID)
      
      return cell
    case .changePin:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
          as DisclosureIndicatorTableViewCell
      presenter.configure(disclosureIndicatorTableViewCell: cell,
                          row: row)
      return cell
    case .version:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
          as RightDetailTableViewCell
      
      presenter.configure(rightDetailCell: cell, row: row)
      return cell
    case .promptTransactionDecisions:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
          as DisclosureIndicatorTableViewCell
      presenter.configure(disclosureIndicatorTableViewCell: cell, row: row)
      return cell
    case .help:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
          as DisclosureIndicatorTableViewCell
      presenter.configure(disclosureIndicatorTableViewCell: cell,
                          row: row)
      return cell
    case .licenses:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
          as DisclosureIndicatorTableViewCell
      presenter.configure(disclosureIndicatorTableViewCell: cell,
                          row: row)
      return cell
    case .logout:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
          as DisclosureIndicatorTableViewCell
      presenter.configure(disclosureIndicatorTableViewCell: cell,
                          row: row)
      return cell
    case .copyright:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
          as CopyrightTableViewCell
      cell.setStaticString()
      return cell
    case .rateUs:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
          as DisclosureIndicatorTableViewCell
      presenter.configure(disclosureIndicatorTableViewCell: cell,
                          row: row)
      return cell
    case .support:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
          as DisclosureIndicatorTableViewCell
      presenter.configure(disclosureIndicatorTableViewCell: cell,
                          row: row)
      return cell
    case .buyCard:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
          as DisclosureIndicatorTableViewCell
      presenter.configure(disclosureIndicatorTableViewCell: cell,
                          row: row)
      return cell
    case .spamProtection:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
        as DisclosureIndicatorTableViewCell
      presenter.configure(disclosureIndicatorTableViewCell: cell, row: row)
      return cell
    case .manageNicknames:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
          as DisclosureIndicatorTableViewCell
      presenter.configure(disclosureIndicatorTableViewCell: cell,
                          row: row)
      return cell
    }  
  }
  
  func tableView(_ tableView: UITableView,
                 titleForHeaderInSection section: Int) -> String? {
    let title = presenter.title(for: section)
    return title
  }
}

// MARK: - SettingsView

extension SettingsViewController: SettingsView {
  
  func setReloadSection() {
    tableView.reloadData()
  }
  
  func setSettings() {
    tableView.reloadData()
  }
  
  func setErrorAlert(for error: Error) {
    UIAlertController.defaultAlert(for: error, presentingViewController: self)
  }
  
  func setDisablePushNotificationAlert() {
    let alert = UIAlertController(title: "Enable Notifications",
                                  message: "Please allow notifications in your iOS system settings for LOBSTR Vault.",
                                  preferredStyle: .alert)
    let settingsAction = UIAlertAction(title: "Settings",
                                       style: .default) { _ in
                                        let url = URL(string: UIApplication.openSettingsURLString)
                                        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    alert.addAction(settingsAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  func setLogoutAlert() {
    var title = L10n.logoutAlertTitle
    var message = L10n.logoutAlertMessage
    
    if UserDefaultsHelper.accountStatus == .createdWithTangem {
      title = "Do you want to log out from this account?"
      message = ""
    }
    
    let alert = UIAlertController(title: title,
                                  message: message, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleLogout, style: .destructive, handler: { _ in
      self.presenter.logoutOperationWasConfirmed()
    }))
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  func setPublicKeyPopover(_ popover: CustomPopoverViewController) {
    present(popover, animated: true, completion: nil)    
  }
}
