import Foundation
import UIKit

protocol SignerDetailsPresenter {
  var countOfAccounts: Int { get }
  var signedAccounts: [SignedAccount] { get }
  
  func configure(_ cell: SignerDetailsTableViewCell, forRow row: Int)
  func signerDetailsViewDidLoad()
  func copyAlertActionWasPressed(for index: Int)
  func openExplorerActionWasPressed(for index: Int)
  func moreDetailsButtonWasPressed(with index: Int)
  func setAccountNicknameActionWasPressed(with text: String?, by index: Int?)
  func clearAccountNicknameActionWasPressed(by index: Int?)
}

class SignerDetailsPresenterImpl {
  
  var signedAccounts: [SignedAccount] = []
  
  private let transactionService: TransactionService
  private let federationService: FederationService
  
  fileprivate weak var view: SignerDetailsView?
  
  private let storage: SignersStorage = SignersStorageDiskImpl()
  private var storageSigners: [SignedAccount] = []
  
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
      
      if let account = storageSigners.first(where: { $0.address == publicKey }) {
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

  func copyAlertActionWasPressed(for index: Int) {
    guard let publicKey = signedAccounts[index].address else { return }
    view?.copy(publicKey)
  }
  
  func openExplorerActionWasPressed(for index: Int) {
    guard let address = signedAccounts[safe: index]?.address else {
      Logger.home.error("Couldn't open stellar expert. Signers list is empty")
      return
    }
       
    UtilityHelper.openStellarExpertForPublicKey(publicKey: address)
  }
  
  func configure(_ cell: SignerDetailsTableViewCell, forRow row: Int) {
    cell.set(signedAccounts[row])
  }
  
  func signerDetailsViewDidLoad() {
    guard let viewController = view as? UIViewController else { return }
    guard UtilityHelper.isTokenUpdated(view: viewController) else { return }
    
    if ConnectionHelper.checkConnection(viewController) {
      self.storageSigners = storage.retrieveSigners() ?? []
      displayAccountList()
    }
  }
  
  func setAccountNicknameActionWasPressed(with text: String?, by index: Int?) {
    guard let index = index, let address = signedAccounts[safe: index]?.address else {
      return
    }
    
    if let index = signedAccounts.firstIndex(where: { $0.address == address }), let nickname = text {
      signedAccounts[index].nickname = nickname
      storage.save(signers: signedAccounts)
      NotificationCenter.default.post(name: .didNicknameSet, object: nil)
      self.view?.reloadRow(index)
    }
  }
  
  func moreDetailsButtonWasPressed(with index: Int) {
    guard let address = signedAccounts[safe: index]?.address else {
      return
    }
    
    if let index = signedAccounts.firstIndex(where: { $0.address == address }) {
      var isNicknameSet = false
      if let nickname = signedAccounts[index].nickname, !nickname.isEmpty {
        isNicknameSet = true
      } else {
        isNicknameSet = false
      }
      self.view?.actionSheetForSignersListWasPressed(with: index, isNicknameSet: isNicknameSet)
    }
  }
  
  func clearAccountNicknameActionWasPressed(by index: Int?) {
    setAccountNicknameActionWasPressed(with: "", by: index)
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
