import UIKit

protocol SettingsView: class {
  func setSettings()
  func setErrorAlert(for error: Error)
  func setLogoutAlert()
}

class SettingsViewController: UIViewController,
  UITableViewDelegate, UITableViewDataSource, StoryboardCreation, SettingsView {
  
  static var storyboardType: Storyboards = .settings
  
  @IBOutlet var tableView: UITableView!
  
  var presenter: SettingsPresenter!

  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setAppearance()
    presenter = SettingsPresenterImpl(view: self,
                                      navigationController: navigationController!)
    
    presenter.settingsViewDidLoad()
  }
  
  // MARK: - Private
  
  func setAppearance() {
    navigationItem.title = L10n.navTitleSettings
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
      return 70
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
      presenter.configure(publicKeyCell: cell)
      return cell
    case .signerForAccounts:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
          as DisclosureIndicatorTableViewCell
      presenter.configure(disclosureIndicatorTableViewCell: cell,
                          row: row)
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
          as BiometricIDTableViewCell
      presenter.configure(biometricIDCell: cell)
      
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
    case .help:
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
    }  
  }
  
  func tableView(_ tableView: UITableView,
                 titleForHeaderInSection section: Int) -> String? {
    let title = presenter.title(for: section)
    return title
  }
  
  // MARK: - SettingsView
  
  func setSettings() {
    tableView.reloadData()
  }
  
  func setErrorAlert(for error: Error) {
    UIAlertController.defaultAlert(for: error, presentingViewController: self)
  }
  
  func setLogoutAlert() {
    let alert = UIAlertController(title: L10n.logoutAlertTitle, message: L10n.logoutAlertMessage, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleLogout, style: .destructive, handler: { _ in
      self.presenter.logoutOperationWasConfirmed()
    }))
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel))
    
    self.present(alert, animated: true, completion: nil)
  }
}
