import Foundation
import UIKit

protocol PublicKeyPresenter {
  func publicKeyViewDidLoad()
  func nextButtonWasPressed()
  func copyKeyButtonWasPressed()
}

protocol PublicKeyView: class {
  func setPublicKey(_ publicKey: String)
  func setProgressAnimation(isDisplay: Bool)
}

class PublicKeyPresenterImpl: PublicKeyPresenter {
  private weak var view: PublicKeyView?
  private let navigationController: UINavigationController
  private let mnemonicManager: MnemonicManager
  private let vaultStorage: VaultStorage
  private let transactionService: TransactionService
  
  private var publicKey: String?
  
  // MARK: - Init
  
  init(view: PublicKeyView,
       navigationController: UINavigationController,
       mnemonicManager: MnemonicManager = MnemonicManagerImpl(),
       transactionService: TransactionService = TransactionService(),
       vaultStorage: VaultStorage = VaultStorage()) {
    self.view = view
    self.navigationController = navigationController
    self.mnemonicManager = mnemonicManager
    self.vaultStorage = vaultStorage
    self.transactionService = transactionService
    
    NotificationCenter.default.addObserver(self, selector: #selector(onDidChangeSignerDetails(_:)), name: .didChangeSignerDetails, object: nil)
  }
  
  @objc func onDidChangeSignerDetails(_ notification: Notification) {
    updateToken()
  }
  
  // MARK: - Private
  
  private func updateToken() {
    view?.setProgressAnimation(isDisplay: true)
    AuthenticationService().updateToken { [weak self] result in
      switch result {
      case .success:
        self?.transitionToNextScreen()
      case .failure(let error):
        self?.view?.setProgressAnimation(isDisplay: false)
        print("Couldn't get token. \(error)")
      }
    }
  }
  
  private func transitionToNextScreen() {
    transactionService.getSignedAccounts() { result in
      switch result {
      case .success(let signedAccounts):
        self.view?.setProgressAnimation(isDisplay: false)
        if signedAccounts.count > 0 {
          ApplicationCoordinatorHelper.setAccountStatus(.created)
          self.transitionToHomeScreen()
        } else {
          self.transitionToRecheckScreen()
        }
      case .failure(let error):
        self.view?.setProgressAnimation(isDisplay: false)
        print("error: \(error)")
      }
    }
  }
  
  private func setData(with publicKey: String) {
    self.publicKey = publicKey
    vaultStorage.storePublicKeyInKeychain(publicKey)
    view?.setPublicKey(publicKey)
    ApplicationCoordinatorHelper.setAccountStatus(.waitingToBecomeSinger)
  }
  
  private func registerForRemoteNotifications() {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    appDelegate?.registerForRemoteNotifications(isStart: false)
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
              self?.setData(with: publicKey)
              self?.registerForRemoteNotifications()
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
  
  func copyKeyButtonWasPressed() {
    UIPasteboard.general.string = publicKey
  }
}

// MARK: - Navigation

extension PublicKeyPresenterImpl {
  
  func transitionToRecheckScreen() {
    let recheckViewController = RecheckViewController.createFromStoryboard()
    
    let publicKeyViewController = view as! PublicKeyViewController
    publicKeyViewController.navigationController?.pushViewController(recheckViewController,
                                                                              animated: true)
  }
  
  func transitionToHomeScreen() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
      else { return }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      appDelegate.applicationCoordinator.showHomeScreen()
    }
  }
}
