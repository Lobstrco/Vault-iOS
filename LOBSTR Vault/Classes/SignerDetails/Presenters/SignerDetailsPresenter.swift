import Foundation
import UIKit

protocol SignerDetailsPresenter {
  var countOfAccounts: Int { get }
  var signedAccounts: [SignedAccount] { get }
  
  func configure(_ cell: SignerDetailsTableViewCell, forRow row: Int)
  func signerDetailsViewDidLoad()
  func moreDetailsButtonWasPressed(for publicKey: String, type: NicknameDialogType)
  func copyAlertActionWasPressed(_ publicKey: String)
  func openExplorerActionWasPressed(_ publicKey: String)
  func setAccountNicknameActionWasPressed(with text: String?, for publicKey: String?)
  func clearAccountNicknameActionWasPressed(_ publicKey: String?)
}

class SignerDetailsPresenterImpl {
  
  var signedAccounts: [SignedAccount] = []
  
  private let transactionService: TransactionService
  private let federationService: FederationService
  
  fileprivate weak var view: SignerDetailsView?
  
  private let storage: AccountsStorage = AccountsStorageDiskImpl()
  private var storageAccounts: [SignedAccount] = []
  
  private var mainAccounts: [SignedAccount] = []
  
  init(view: SignerDetailsView,
       transactionService: TransactionService = TransactionService(),
       federationService: FederationService = FederationService()) {
    self.view = view
    self.transactionService = transactionService
    self.federationService = federationService
    addObservers()
  }    
  
  func displayAccountList() {
    view?.setProgressAnimation()
    transactionService.getSignedAccounts() { result in
      switch result {
      case .success(let signedAccounts):
        self.signedAccounts = signedAccounts
        self.setFederations(to: &self.signedAccounts)
        AccountsStorageHelper.updateAllSignedAccounts(signedAccounts: self.signedAccounts)
        self.view?.setAccountList(isEmpty: self.signedAccounts.isEmpty)
      case .failure(let error):
        Logger.networking.error("Couldn't get signed accounts with error: \(error)")
      }
    }
  }
  
  @objc func onDidJWTTokenUpdate(_ notification: Notification) {
    displayAccountList()
  }
  
}

private extension SignerDetailsPresenterImpl {
  func setFederations(to accounts: inout [SignedAccount]) {
    for (index, account) in accounts.enumerated() {
      guard let publicKey = account.address else { break }
      
      if let account = storageAccounts.first(where: { $0.address == publicKey }) {
        accounts[index].nickname = account.nickname
        accounts[index].federation = account.federation
      } else {
        if let result = CoreDataStack.shared.fetch(Account.fetchBy(publicKey: publicKey)).first {
          accounts[index].federation = result.federation
        } else {
          tryToLoadFederation(by: publicKey, for: index)
        }
      }
    }
  }
  
  func tryToLoadFederation(by publicKey: String, for index: Int) {
    federationService.getFederation(for: publicKey) { result in
      switch result {
      case .success(let account):
        if let federation = account.federation {
          self.signedAccounts[index] = SignedAccount(address: account.publicKey, federation: federation)
          AccountsStorageHelper.updateAllSignedAccounts(signedAccounts: self.signedAccounts)
          self.view?.reloadRow(index)
        }
      case .failure(let error):
        Logger.home.error("Couldn't get federation for \(publicKey) with error: \(error)")
      }
    }
  }
}

extension SignerDetailsPresenterImpl: SignerDetailsPresenter {
  
  var countOfAccounts: Int {
    return signedAccounts.count
  }

  func copyAlertActionWasPressed(_ publicKey: String) {
    view?.copy(publicKey)
  }
  
  func openExplorerActionWasPressed(_ publicKey: String) {
    UtilityHelper.openStellarExpertForPublicKey(publicKey: publicKey)
  }
  
  func configure(_ cell: SignerDetailsTableViewCell, forRow row: Int) {
    cell.set(signedAccounts[row])
  }
  
  func signerDetailsViewDidLoad() {
    guard let viewController = view as? UIViewController else { return }
    guard UtilityHelper.isTokenUpdated(view: viewController) else { return }
    
    if ConnectionHelper.checkConnection(viewController) {
      self.storageAccounts = storage.retrieveAccounts() ?? []
      self.mainAccounts = AccountsStorageHelper.getMainAccountsFromCache()
      displayAccountList()
    }
  }
  
  func setAccountNicknameActionWasPressed(with text: String?, for publicKey: String?) {
    guard let publicKey = publicKey else { return }
    
    var allAccounts: [SignedAccount] = []
    allAccounts.append(contentsOf: mainAccounts)
    
    if let index = signedAccounts.firstIndex(where: { $0.address == publicKey }), let nickname = text {
      signedAccounts[index].nickname = nickname
      AccountsStorageHelper.updateAllSignedAccounts(signedAccounts: signedAccounts)
      allAccounts.append(contentsOf: AccountsStorageHelper.allSignedAccounts)
      storage.save(accounts: allAccounts)
      NotificationCenter.default.post(name: .didNicknameSet, object: nil)
      self.view?.reloadRow(index)
    }
  }
  
  func moreDetailsButtonWasPressed(for publicKey: String, type: NicknameDialogType) {
    if let index = signedAccounts.firstIndex(where: { $0.address == publicKey }) {
      var isNicknameSet = false
      if let nickname = signedAccounts[index].nickname, !nickname.isEmpty {
        isNicknameSet = true
      } else {
        isNicknameSet = false
      }
      self.view?.actionSheetForSignersListWasPressed(with: publicKey, isNicknameSet: isNicknameSet)
    }
  }
  
  func clearAccountNicknameActionWasPressed(_ publicKey: String?) {
    setAccountNicknameActionWasPressed(with: "", for: publicKey)
  }
}

// MARK: - Private

private extension SignerDetailsPresenterImpl {
  
  func addObservers() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidJWTTokenUpdate(_:)),
                                           name: .didJWTTokenUpdate,
                                           object: nil)
  }
  
}
