import UIKit

protocol BiometricIDPresenter {
  func biometricIDViewDidLoad()
  func turnOnButtonWasPressed()
  func skipButtonWasPressed()
}

protocol BiometricIDView: class {
  func setErrorAlert(for error: Error)
  func setBiometricButton(with type: BiometricType)
  func setProgressAnimation(isDisplay: Bool)
}

class BiometricIDPresenterImpl: BiometricIDPresenter {
  private weak var view: BiometricIDView?
  private let navigationController: UINavigationController
  private var biometricAuthManager: BiometricAuthManager
  
  private let transactionService: TransactionService

  // MARK: - Init

  init(view: BiometricIDView,
       navigationController: UINavigationController,
       transactionService: TransactionService = TransactionService(),
       biometricAuthManager: BiometricAuthManager = BiometricAuthManagerImpl()) {
    self.view = view
    self.navigationController = navigationController
    self.transactionService = transactionService
    self.biometricAuthManager = biometricAuthManager
  }
}

// MARK: - BiometricIDPresenter

extension BiometricIDPresenterImpl {
  
  func biometricIDViewDidLoad() {
    view?.setBiometricButton(with: Device.biometricType)
  }

  func turnOnButtonWasPressed() {
    biometricAuthManager.authenticateUser { [weak self] result in
      switch result {
      case .success:
        self?.biometricAuthManager.isBiometricAuthEnabled = true
        self?.updateToken()
      case .failure(let error):
        guard let error = error as? VaultError.BiometricError  else { return }
        guard error == VaultError.BiometricError.notAvailable else { return }
        self?.view?.setErrorAlert(for: error)
      }
    }
  }
  
  func skipButtonWasPressed() {
    updateToken()
  }
}

// MARK: - Navigation

extension BiometricIDPresenterImpl {
  
  private func updateToken() {
    guard let viewController = view as? UIViewController else {
      return
    }
    
    guard ConnectionHelper.checkConnection(viewController) else {
      return
    }
    
    view?.setProgressAnimation(isDisplay: true)
    AuthenticationService().updateToken { [weak self] result in
      switch result {
      case .success:
        self?.transitionToNextScreen()
      case .failure(let error):
        self?.view?.setProgressAnimation(isDisplay: false)
        Logger.auth.error("Couldn't get token with error: \(error)")
      }
    }
  }
  
  private func transitionToNextScreen() {
    UserDefaultsHelper.accountStatus = .createdByDefault
    self.transitionToHomeScreen()
//    transactionService.getSignedAccounts() { result in
//      switch result {
//      case .success(let signedAccounts):
//        self.view?.setProgressAnimation(isDisplay: false)
//        if signedAccounts.count > 0 {
//          UserDefaultsHelper.accountStatus = .created
//          self.transitionToHomeScreen()
//        } else {
//          self.transitionToPublicKey()
//        }
//      case .failure(let error):
//        self.view?.setProgressAnimation(isDisplay: false)
//        Logger.transactions.error("Couldn't get signed accounts with error: \(error)")
//      }
//    }
  }
  
  func transitionToHomeScreen() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
      else { return }
    UserDefaultsHelper.isAfterLogin = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      appDelegate.applicationCoordinator.showHomeScreen()
    }
  }
}
