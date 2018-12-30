import Foundation
import stellarsdk

enum SettingsSectionType {
  case wallet
  
  var title: String {
    switch self {
    case .wallet:
      return "Wallet"
    }
  }
}

enum SettingsRow {
  case publicKey
}

struct SettingsSection {
  var type: SettingsSectionType
  var rows: [SettingsRow]
}

protocol SettingsPresenter {
  
  func numberOfSections() -> Int
  func numberOfRows(in section: Int) -> Int
  
  func row(for indexPath: IndexPath) -> SettingsRow
  func title(for section: Int) -> String
  
  func settingsViewDidLoad()
  
  func configure(publicKeyCell: PublicKeyTableViewCell)
}

class SettingsPresenterImpl: SettingsPresenter {
  private weak var view: SettingsView?
  private var sections: [SettingsSection] = []
  private let mnemonicManager: MnemonicManager
  
  // MARK: - Init
  
  init(view: SettingsView,
       mnemonicManager: MnemonicManager = MnemonicManagerImpl()) {
    self.view = view
    self.mnemonicManager = mnemonicManager
  }
  
  // MARK: - SettingsPresenter
  
  func settingsViewDidLoad() {
    sections = [SettingsSection(type: .wallet, rows: [.publicKey])]
    view?.showSettings()
  }
  
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
  
  func configure(publicKeyCell: PublicKeyTableViewCell) {
    // With use autoreleasepool we clear sensitive memory immediately.
    autoreleasepool {
      mnemonicManager.getDecryptedMnemonicFromKeychain { result in
        switch result {
        case .success(let mnemonic):
          let keyPair = MnemonicHelper.getKeyPairFrom(mnemonic)
          publicKeyCell.display(keyPair.accountId)
        case .failure:
          break
        }
      }
    }
  }
}
