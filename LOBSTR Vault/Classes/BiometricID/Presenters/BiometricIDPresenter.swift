import UIKit

protocol BiometricIDPresenter {
  func biometricIDViewDidLoad()
  func turnOnButtonWasPressed()
  func skipButtonWasPressed()
}

class BiometricIDPresenterImpl: BiometricIDPresenter {
  private weak var view: BiometricIDView?
  private var biometricAuthManager: BiometricAuthManager

  // MARK: - Init

  init(view: BiometricIDView,
       biometricAuthManager: BiometricAuthManager = BiometricAuthManagerImpl()) {
    self.view = view
    self.biometricAuthManager = biometricAuthManager
  }
}

// MARK: - BiometricIDPresenter

extension BiometricIDPresenterImpl {
  func biometricIDViewDidLoad() {
    let title = "Protect your wallet"
    view?.setTitle(title)
  }

  func turnOnButtonWasPressed() {
    biometricAuthManager.authenticateUser { [weak self] result in
      switch result {
      case .success:
        self?.biometricAuthManager.isBiometricAuthEnabled = true
        self?.transitionToHomeScreen()
      case .failure(let error):
        guard let error = error as? VaultError.BiometricError  else { return }
        self?.view?.setErrorAlert(for: error)
      }
    }
  }
  
  func skipButtonWasPressed() {
    transitionToHomeScreen()
  }
}

// MARK: - Navigation

extension BiometricIDPresenterImpl {
  func transitionToHomeScreen() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
    else { return }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      appDelegate.applicationCoordinator.showHomeScreen()
    }
  }
}
