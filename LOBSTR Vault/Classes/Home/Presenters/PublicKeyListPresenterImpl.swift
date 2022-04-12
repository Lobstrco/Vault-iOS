import Foundation
import stellarsdk

class PublicKeyListPresenterImpl: PublicKeyListPresenter {
  
  var accounts: [SignedAccount] = []
  
  private weak var view: PublicKeyListView?
  private let transactionService: TransactionService
  private let vaultStorage: VaultStorage
  private let mnemonicManager: MnemonicManager
  private let publicKeyListDelegate: PublicKeyListDelegate?
    
  init(view: PublicKeyListView,
       transactionService: TransactionService = TransactionService(),
       mnemonicManager: MnemonicManager = MnemonicManagerImpl(),
       vaultStorage: VaultStorage = VaultStorage(),
       publicKeyListDelegate: PublicKeyListDelegate?) {
    self.view = view
    self.transactionService = transactionService
    self.mnemonicManager = mnemonicManager
    self.vaultStorage = vaultStorage
    self.publicKeyListDelegate = publicKeyListDelegate
  }
  
  
  // MARK: - PublicKeyListPresenter
  func homeViewDidLoad() {
    getAccounts()
  }
  
  func accountWasSelected(by index: Int) {
    guard let publicKey = accounts[index].address else { return }
    UserDefaultsHelper.activePublicKey = publicKey
    ActivePublicKeyHelper.storeInKeychain(publicKey)
    UserDefaultsHelper.activePublicKeyIndex = index
    publicKeyListDelegate?.publicKeyWasSelected()
  }
  
  func addNewAccount() {
    guard mnemonicManager.isMnemonicStoredInKeychain() else {
      Logger.mnemonic.error("Mnemonic doesn't exist")
      return
    }
        
    mnemonicManager.getDecryptedMnemonicFromKeychain { result in
      switch result {
      case .success(let mnemonic):
        var publicKeys: [String] = []
        if let publicKeysCount = self.vaultStorage.getPublicKeysFromKeychain()?.count {
          for index in 0...publicKeysCount {
            let keyPair = MnemonicHelper.getKeyPairFrom(mnemonic, index: index)
            publicKeys.append(keyPair.accountId)
          }
        } else if self.vaultStorage.getPublicKeyFromKeychain() != nil {
          for index in 0...1 {
            let keyPair = MnemonicHelper.getKeyPairFrom(mnemonic, index: index)
            publicKeys.append(keyPair.accountId)
          }
        }
        
        if !publicKeys.isEmpty {
          if self.vaultStorage.removePublicKeysFromKeychain() {
            self.vaultStorage.storePublicKeysInKeychain(publicKeys)
            if let publicKeysFromKeychain = self.vaultStorage.getPublicKeysFromKeychain() {
              PromtForTransactionDecisionsHelper.setPromtForTransactionDecisionsStatusesDefaultValues()
              UserDefaultsHelper.activePublicKey = publicKeysFromKeychain.last ?? ""
              ActivePublicKeyHelper.storeInKeychain(UserDefaultsHelper.activePublicKey)
              UserDefaultsHelper.activePublicKeyIndex = publicKeysFromKeychain.count - 1
              UserDefaultsHelper.pushNotificationsStatuses[UserDefaultsHelper.activePublicKey] = true
              self.publicKeyListDelegate?.publicKeyWasSelected()
              self.view?.dismiss()
            }
          }
        }
      case .failure:
        break
      }
    }
  }
}

// MARK: - Private

private extension PublicKeyListPresenterImpl {
  
  func getAccounts() {
    accounts = AccountsStorageHelper.getMainAccountsFromCache()
    view?.setAccounts(accounts)
  }
}

