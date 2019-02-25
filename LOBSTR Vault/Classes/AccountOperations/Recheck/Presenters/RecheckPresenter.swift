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
}

class RecheckPresenterImpl {
  
  fileprivate weak var view: RecheckView?
  private let transactionService: TransactionService
  
  init(view: RecheckView, transactionService: TransactionService = TransactionService()) {
    self.view = view
    self.transactionService = transactionService
  }
  
  func getSignerDetails() {
    view?.setProgressAnimation(isDisplay: true)
    transactionService.getSignedAccounts() { result in
      switch result {
      case .success(let signedAccounts):
        self.view?.setProgressAnimation(isDisplay: false)
        if signedAccounts.count > 0 {
          ApplicationCoordinatorHelper.setAccountStatus(.created)
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
  
  func transitionToHomeScreen() {
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
