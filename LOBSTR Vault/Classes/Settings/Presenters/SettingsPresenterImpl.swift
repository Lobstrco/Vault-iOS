import Foundation
import stellarsdk

class SettingsPresenterImpl: SettingsPresenter {
  private weak var view: SettingsView?
  private var sections: [SettingsSection] = []
  private let mnemonicManager: MnemonicManager
  private let navigationController: UINavigationController
  
  // MARK: - Init
  
  init(view: SettingsView,
       navigationController: UINavigationController,
       mnemonicManager: MnemonicManager = MnemonicManagerImpl()) {
    self.view = view
    self.navigationController = navigationController
    self.mnemonicManager = mnemonicManager
  }
}

// MARK: - SettingsLifeCycle

extension SettingsPresenterImpl {
  func settingsViewDidLoad() {
    let wallet = SettingsSection(type: .account, rows: [.publicKey])
    
    var securityRows: [SettingsRow] = []
    
    if Device.biometricType != .none {
      securityRows = [.mnemonicCode, .biometricId, .changePin]
    } else {
      securityRows = [.mnemonicCode, .changePin]
    }
    
    let security = SettingsSection(type: .security,
                                   rows: securityRows)
    
    let about = SettingsSection(type: .about, rows: [.version, .help])
    
    sections = [wallet, security, about]
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
    // With use autoreleasepool we clear sensitive memory immediately.
    autoreleasepool {
      mnemonicManager.getDecryptedMnemonicFromKeychain { result in
        switch result {
        case .success(let mnemonic):
          DispatchQueue.global(qos: .userInteractive).async {
            let keyPair = MnemonicHelper.getKeyPairFrom(mnemonic)
            DispatchQueue.main.async {
              publicKeyCell.setPublicKey(keyPair.accountId)
            }
          }
        case .failure:
          break
        }
      }
    }
  }
  
  func configure(biometricIdCell: BiometricIdTableViewCell) {
    biometricIdCell.setTitle(Device.biometricType.name)
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

// MARK: -  Coordinator

extension SettingsPresenterImpl {
  func showChangePin() {
    guard let pinViewController = PinViewController.createFromStoryboard()
    else { fatalError() }
    
    pinViewController.hidesBottomBarWhenPushed = true
    pinViewController.mode = .changePin
    
    navigationController.pushViewController(pinViewController, animated: true)
  }
}
