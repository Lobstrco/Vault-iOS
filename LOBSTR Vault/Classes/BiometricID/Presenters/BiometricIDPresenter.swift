import UIKit

protocol BiometricIDPresenter {
  func biometricIDViewDidLoad()
  func turnOnButtonWasPressed()
  func skipButtonWasPressed()
}

class BiometricIDPresenterImpl: BiometricIDPresenter {
  private weak var view: BiometricIDView?
  private let navigationController: UINavigationController
  private var biometricAuthManager: BiometricAuthManager

  // MARK: - Init

  init(view: BiometricIDView,
       navigationController: UINavigationController,
       biometricAuthManager: BiometricAuthManager = BiometricAuthManagerImpl()) {
    self.view = view
    self.navigationController = navigationController
    self.biometricAuthManager = biometricAuthManager
  }
}

// MARK: - BiometricIDPresenter

extension BiometricIDPresenterImpl {
  
  func biometricIDViewDidLoad() {
    
  }

  func turnOnButtonWasPressed() {
    biometricAuthManager.authenticateUser { [weak self] result in
      switch result {
      case .success:
        self?.biometricAuthManager.isBiometricAuthEnabled = true
        self?.transitionToPublicKey()
      case .failure(let error):
        guard let error = error as? VaultError.BiometricError  else { return }
        self?.view?.setErrorAlert(for: error)
      }
    }
  }
  
  func skipButtonWasPressed() {
    transitionToPublicKey()
  }
}

// MARK: - Navigation

extension BiometricIDPresenterImpl {
  func transitionToPublicKey() {
    let publicKeyViewController = PublicKeyViewController.createFromStoryboard()
    
    navigationController.pushViewController(publicKeyViewController,
                                            animated: true)
  }
}
