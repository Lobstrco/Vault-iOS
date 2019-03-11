import Foundation
import UIKit

protocol RecheckPresenter {
  func recheckButtonWasPressed()
  func logoutButtonWasPressed()
  func logoutOperationWasConfirmed()
}

protocol RecheckView: class {
  func setProgressAnimation(isDisplay: Bool)
  func setLogoutAlert()
  func setPublicKey(_ publicKey: String)
}

class RecheckPresenterImpl {
  
  fileprivate weak var view: RecheckView?
  private let transactionService: TransactionService
  private let vaultStorage: VaultStorage
  
  init(view: RecheckView,
       transactionService: TransactionService = TransactionService(),
       vaultStorage: VaultStorage = VaultStorage()) {
    self.view = view
    self.transactionService = transactionService
    self.vaultStorage = vaultStorage
    
    setPublicKey()
  }
  
  // MARK: - Private
  
  private func setPublicKey() {
    guard let publicKey = vaultStorage.getPublicKeyFromKeychain() else { return }
    view?.setPublicKey(publicKey)
  }
  
  private func getSignerDetails() {
    view?.setProgressAnimation(isDisplay: true)
    transactionService.getSignedAccounts() { result in
      switch result {
      case .success(let signedAccounts):
        self.view?.setProgressAnimation(isDisplay: false)
        if signedAccounts.count > 0 {
          UserDefaultsHelper.accountStatus = .created
          self.transitionToHomeScreen()
        } else {
          // show something for user
        }
      case .failure(let error):
        self.view?.setProgressAnimation(isDisplay: false)
        print("error: \(error)")
      }
    }
  }
  
  private func transitionToHomeScreen() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
      else { return }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      appDelegate.applicationCoordinator.showHomeScreen()
    }
  }
}

// MARK: - RecheckPresenter

extension RecheckPresenterImpl: RecheckPresenter {
  
  func recheckButtonWasPressed() {
    guard let viewController = view as? UIViewController else {
      return
    }
    
    if ConnectionHelper.checkConnection(viewController) {
      getSignerDetails()
    }
  }
  
  func logoutButtonWasPressed() {
    view?.setLogoutAlert()
  }
  
  func logoutOperationWasConfirmed() {
    ApplicationCoordinatorHelper.logout()
  }
}
