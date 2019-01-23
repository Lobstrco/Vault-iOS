import Foundation
import UIKit

protocol PublicKeyPresenter {
  func publicKeyViewDidLoad()
  func nextButtonWasPressed()
}

class PublicKeyPresenterImpl: PublicKeyPresenter {
  private weak var view: PublicKeyView?
  private let navigationController: UINavigationController
  private let mnemonicManager: MnemonicManager
  private let vaultStorage: VaultStorage
  
  // MARK: - Init
  
  init(view: PublicKeyView,
       navigationController: UINavigationController,
       mnemonicManager: MnemonicManager = MnemonicManagerImpl(),
       vaultStorage: VaultStorage = VaultStorage()) {
    self.view = view
    self.navigationController = navigationController
    self.mnemonicManager = mnemonicManager
    self.vaultStorage = vaultStorage
  }
  
  // MARK: - Private
  
  private func updateToken() {
    AuthenticationService().updateToken { [weak self] result in
      switch result {
      case .success:
        self?.transitionToHomeScreen()
      case .failure(let error):
        print("Couldn't get token. \(error)")
      }
    }
  }
  
  // MARK: - PublicKeyPresenter
  
  func publicKeyViewDidLoad() {
    autoreleasepool {
      mnemonicManager.getDecryptedMnemonicFromKeychain { [weak self] result in
        switch result {
        case .success(let mnemonic):
          DispatchQueue.global(qos: .userInteractive).async {
            let keyPair = MnemonicHelper.getKeyPairFrom(mnemonic)
            DispatchQueue.main.async {
              let publicKey = keyPair.accountId
              self?.vaultStorage.storePublicKeyInKeychain(publicKey)
              self?.view?.setPublicKey(publicKey)
            }
          }
        case .failure:
          break
        }
      }
    }
  }
  
  func nextButtonWasPressed() {
    updateToken()
  }
}

// MARK: - Navigation

extension PublicKeyPresenterImpl {
  func transitionToHomeScreen() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
    else { return }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      appDelegate.applicationCoordinator.showHomeScreen()
    }
  }
}
