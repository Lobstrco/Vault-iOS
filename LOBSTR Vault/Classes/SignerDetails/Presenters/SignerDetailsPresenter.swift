import Foundation
import UIKit

protocol SignerDetailsPresenter {
  var countOfAccounts: Int { get }
  func configure(_ cell: SignerDetailsTableViewCell, forRow row: Int)
  func signerDetailsViewDidLoad()
  func copyAlertActionWasPressed(for index: Int)
  func openExplorerActionWasPressed(for index: Int)
}

class SignerDetailsPresenterImpl {
  
  var accounts: [SignedAccount] = []
  
  private let transactionService: TransactionService
  private let federationService: FederationService
  
  fileprivate weak var view: SignerDetailsView?
  
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
        self.accounts = signedAccounts
        self.setFederations(to: &self.accounts)
        self.view?.setAccountList(isEmpty: self.accounts.isEmpty)
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
      if let result = CoreDataStack.shared.fetch(Account.fetchBy(publicKey: publicKey)).first {
        accounts[index].federation = result.federation
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
          self.accounts[index] = SignedAccount(address: account.publicKey, federation: federation)
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
    return accounts.count
  }

  func copyAlertActionWasPressed(for index: Int) {
    guard let publicKey = accounts[index].address else { return }
    view?.copy(publicKey)
  }
  
  func openExplorerActionWasPressed(for index: Int) {
    guard let address = accounts[safe: index]?.address else {
      Logger.home.error("Couldn't open stellar expert. Signers list is empty")
      return
    }
       
    UtilityHelper.openStellarExpert(for: address)
  }
  
  func configure(_ cell: SignerDetailsTableViewCell, forRow row: Int) {
    cell.set(accounts[row])
  }
  
  func signerDetailsViewDidLoad() {
    guard let viewController = view as? UIViewController else { return }
    guard UtilityHelper.isTokenUpdated(view: viewController) else { return }
    
    if ConnectionHelper.checkConnection(viewController) {
      displayAccountList()
    }
    
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
