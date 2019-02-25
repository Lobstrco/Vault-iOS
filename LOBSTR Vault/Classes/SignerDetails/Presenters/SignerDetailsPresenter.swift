import Foundation
import UIKit

protocol SignerDetailsPresenter {
  var countOfAccounts: Int { get }
  func configure(_ cell: SignerDetailsTableViewCell, forRow row: Int)
  func signerDetailsViewDidLoad()
  func copyAlertActionWasPressed(for index: Int)
}

class SignerDetailsPresenterImpl {
  
  var accounts: [SignedAccounts] = []
  
  private let transactionService: TransactionService
  
  fileprivate weak var view: SignerDetailsView?
  
  init(view: SignerDetailsView,
       transactionService: TransactionService = TransactionService()) {
    self.view = view
    self.transactionService = transactionService
  }    
  
  func displayAccountList() {
    view?.setProgressAnimation()
    transactionService.getSignedAccounts() { result in
      switch result {
      case .success(let signedAccounts):
        self.accounts = signedAccounts        
        self.view?.setAccountList(isEmpty: self.accounts.isEmpty)
      case .failure(let error):
        print("error: \(error)")
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
  
  func configure(_ cell: SignerDetailsTableViewCell, forRow row: Int) {
    guard let address = accounts[row].address else {
      return
    }
    
    cell.setPublicKey(address)
  }
  
  func signerDetailsViewDidLoad() {
    guard let viewController = view as? UIViewController else {
      return
    }
    
    if ConnectionHelper.checkConnection(viewController) {
      displayAccountList()
    }
    
  }
}
