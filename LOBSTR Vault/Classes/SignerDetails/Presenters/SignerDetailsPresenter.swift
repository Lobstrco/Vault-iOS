import Foundation
import UIKit

protocol SignerDetailsPresenter {
  var countOfAccounts: Int { get }
  var signedAccounts: [SignedAccount] { get }
  var sortedNicknames: [SignedAccount] { get }
  
  func configure(_ cell: SignerDetailsTableViewCell, forRow row: Int)
  func signerDetailsViewDidLoad()
  func moreDetailsButtonWasPressed(for publicKey: String)
  func copyAlertActionWasPressed(_ publicKey: String)
  func openExplorerActionWasPressed(_ publicKey: String)
  func setNicknameActionWasPressed(with text: String?, for publicKey: String?)
  func clearNicknameActionWasPressed(_ publicKey: String?)
  func addNicknameButtonWasPressed()
  func proceedICloudSyncActionWasPressed()
}

class SignerDetailsPresenterImpl {
  
  var signedAccounts: [SignedAccount] = []
  
  private let transactionService: TransactionService
  private let federationService: FederationService
  
  fileprivate weak var view: SignerDetailsView?
  private let screenType: SignerDetailsScreenType
  
  private let storage: AccountsStorage = AccountsStorageDiskImpl()
  private var storageAccounts: [SignedAccount] = []
  
  private var mainAccounts: [SignedAccount] = []
  
  var sortedNicknames: [SignedAccount] = []
  
  init(view: SignerDetailsView,
       screenType: SignerDetailsScreenType,
       transactionService: TransactionService = TransactionService(),
       federationService: FederationService = FederationService()) {
    self.view = view
    self.screenType = screenType
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
  
  func displayNicknamesList() {
    sortedNicknames = storageAccounts.filter({ !($0.nickname ?? "").isEmpty })
    sortedNicknames = sortedNicknames.sorted { (firstAccount, secondAccount) -> Bool in
      let firstNickname = firstAccount.nickname ?? ""
      let secondNickname = secondAccount.nickname ?? ""
      return (firstNickname.localizedCaseInsensitiveCompare(secondNickname) == .orderedAscending)
    }
    self.view?.setAccountList(isEmpty: sortedNicknames.isEmpty)
  }
}

private extension SignerDetailsPresenterImpl {
  func setFederations(to accounts: inout [SignedAccount]) {
    for (index, account) in accounts.enumerated() {
      guard let publicKey = account.address else { break }
      
      if let account = storageAccounts.first(where: { $0.address == publicKey }) {
        accounts[index].nickname = account.nickname
        accounts[index].federation = account.federation
        accounts[index].indicateAddress = AccountsStorageHelper.indicateAddress
      } else {
        tryToLoadFederation(by: publicKey, for: index)
      }
    }
  }
  
  func tryToLoadFederation(by publicKey: String, for index: Int) {
    federationService.getFederation(for: publicKey) { result in
      switch result {
      case .success(let account):
        if let federation = account.federation {
          self.signedAccounts[index] = SignedAccount(address: account.publicKey, federation: federation, indicateAddress: AccountsStorageHelper.indicateAddress)
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
    return screenType == .protectedAccounts ? signedAccounts.count : sortedNicknames.count
  }

  func copyAlertActionWasPressed(_ publicKey: String) {
    view?.copy(publicKey)
  }
  
  func openExplorerActionWasPressed(_ publicKey: String) {
    UtilityHelper.openStellarExpertForPublicKey(publicKey: publicKey)
  }
  
  func configure(_ cell: SignerDetailsTableViewCell, forRow row: Int) {
    switch screenType {
    case .protectedAccounts:
      cell.set(signedAccounts[row])
    case .manageNicknames:
      cell.set(sortedNicknames[row])
    }
  }
  
  func signerDetailsViewDidLoad() {
    self.storageAccounts = AccountsStorageHelper.getStoredAccounts()
    switch screenType {
    case .protectedAccounts:
      guard let viewController = view as? UIViewController else { return }
      guard UtilityHelper.isTokenUpdated(view: viewController) else { return }
      
      if ConnectionHelper.checkConnection(viewController) {
        self.mainAccounts = AccountsStorageHelper.getMainAccountsFromCache()
        displayAccountList()
      }
    case .manageNicknames:
      displayNicknamesList()
    }
  }
  
  func setNicknameActionWasPressed(with text: String?, for publicKey: String?) {
    guard let publicKey = publicKey else { return }
    
    switch screenType {
    case .protectedAccounts:
      var allAccounts: [SignedAccount] = []
      allAccounts.append(contentsOf: mainAccounts)
      allAccounts.append(contentsOf: AccountsStorageHelper.getAllOtherAccounts())
      
      if let index = signedAccounts.firstIndex(where: { $0.address == publicKey }), let nickname = text {
        signedAccounts[index].nickname = nickname
        AccountsStorageHelper.updateAllSignedAccounts(signedAccounts: signedAccounts)
        allAccounts.append(contentsOf: AccountsStorageHelper.allSignedAccounts)
        storage.save(accounts: allAccounts)
        savedToICloud(account: signedAccounts[index])
        NotificationCenter.default.post(name: .didNicknameSet, object: nil)
        self.view?.reloadRow(index)
      }
    case .manageNicknames:
      if let index = storageAccounts.firstIndex(where: { $0.address == publicKey }), let nickname = text {
        storageAccounts[index].nickname = nickname
        storage.save(accounts: storageAccounts)
        savedToICloud(account: storageAccounts[index])
        NotificationCenter.default.post(name: .didActivePublicKeyChange, object: nil)
        NotificationCenter.default.post(name: .didNicknameSet, object: nil)
        signerDetailsViewDidLoad()
      }
    }
    
    guard UIDevice.isConnectedToNetwork,
          let nickname = text,
          !nickname.isEmpty else { return }
    
    CloudKitNicknameHelper.checkIsICloudStatusAvaliable { isAvaliable in
      if isAvaliable {
        CloudKitNicknameHelper.isICloudDatabaseEmpty { result in
          if result, CloudKitNicknameHelper.isNeedToShowICloudSyncAdviceAlert {
            DispatchQueue.main.async {
              UserDefaultsHelper.isICloudSyncAdviceShown = true
              self.view?.showICloudSyncAdviceAlert()
            }
          }
        }
      }
    }
  }
  
  func moreDetailsButtonWasPressed(for publicKey: String) {
    switch screenType {
    case .protectedAccounts:
      if let index = signedAccounts.firstIndex(where: { $0.address == publicKey }) {
        var isNicknameSet = false
        if let nickname = signedAccounts[index].nickname, !nickname.isEmpty {
          isNicknameSet = true
        } else {
          isNicknameSet = false
        }
        self.view?.actionSheetForSignersListWasPressed(with: publicKey, isNicknameSet: isNicknameSet)
      }
    case .manageNicknames:
      
      
      self.view?.actionSheetForSignersListWasPressed(with: publicKey,
                                                     isNicknameSet: true)
    }
  }
  
  func clearNicknameActionWasPressed(_ publicKey: String?) {
    if UserDefaultsHelper.isICloudSynchronizationEnabled {
      guard UIDevice.isConnectedToNetwork else {
        view?.showNoInternetConnectionAlert()
        return
      }
      setNicknameActionWasPressed(with: "", for: publicKey)
    } else {
      setNicknameActionWasPressed(with: "", for: publicKey)
    }
  }
  
  func addNicknameButtonWasPressed() {
    transitionToAddNickname()
  }
    
  func proceedICloudSyncActionWasPressed() {
    view?.showICloudSyncScreen()
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
  
  func transitionToAddNickname() {
    let addNicknameViewController = AddNicknameViewController.createFromStoryboard()
    addNicknameViewController.delegate = self
    let signerDetailsViewController = view as! SignerDetailsViewController
    signerDetailsViewController.navigationController?.present(addNicknameViewController, animated: true, completion: nil)
  }
  
  func savedToICloud(account: SignedAccount?) {
    CloudKitNicknameHelper.accountToSave = account
    if let accountToSave = CloudKitNicknameHelper.accountToSave {
      CloudKitNicknameHelper.saveToICloud(accountToSave)
    }
  }
}

// MARK: - AddNicknameDelegate

extension SignerDetailsPresenterImpl: AddNicknameDelegate {
  func nicknameWasAdded() {
    signerDetailsViewDidLoad()
  }
  
  func showICloudSyncAdviceAlert() {
    view?.showICloudSyncAdviceAlert()
  }
  
  func showNoInternetConnectionAlert() {
    view?.showNoInternetConnectionAlert()
  }
}
