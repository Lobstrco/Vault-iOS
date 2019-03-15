import Foundation
import UIKit

protocol PublicKeyPresenter {
  func publicKeyViewDidLoad()
  func nextButtonWasPressed()
  func copyKeyButtonWasPressed()
  func logoutButtonWasPressed()
  func logoutOperationWasConfirmed()
  func helpButtonWasPressed()
}

protocol PublicKeyView: class {
  func setPublicKey(_ publicKey: String)
  func setProgressAnimation(isDisplay: Bool)
  func setQRCode(from publicKey: String)
  func setLogoutAlert()
}

class PublicKeyPresenterImpl: PublicKeyPresenter {
  private weak var view: PublicKeyView?
  private let navigationController: UINavigationController
  private let mnemonicManager: MnemonicManager
  private let vaultStorage: VaultStorage
  private let transactionService: TransactionService
  private let notificationManager: NotificationManager
  
  private var publicKey: String?
  
  // MARK: - Init
  
  init(view: PublicKeyView,
       navigationController: UINavigationController,
       mnemonicManager: MnemonicManager = MnemonicManagerImpl(),
       transactionService: TransactionService = TransactionService(),
       notificationRegistrator: NotificationManager = NotificationManager(),
       vaultStorage: VaultStorage = VaultStorage()) {
    self.view = view
    self.navigationController = navigationController
    self.mnemonicManager = mnemonicManager
    self.vaultStorage = vaultStorage
    self.transactionService = transactionService
    self.notificationManager = notificationRegistrator
  }
  
  // MARK: - Private
  
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
          UserDefaultsHelper.accountStatus = .created
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
  
  private func registerForRemoteNotifications() {
    notificationManager.requestAuthorization() { isGranted in
      UserDefaultsHelper.isNotificationsEnabled = isGranted
      self.notificationManager.sendFCMTokenToServer()
    }
  }
  
  // MARK: - PublicKeyPresenter
  
  func publicKeyViewDidLoad() {
    guard let publicKey = vaultStorage.getPublicKeyFromKeychain() else { return }
    self.publicKey = publicKey
    
    view?.setPublicKey(publicKey)
    view?.setQRCode(from: publicKey)
    registerForRemoteNotifications()
    
    UserDefaultsHelper.accountStatus = .waitingToBecomeSinger
  }
  
  func nextButtonWasPressed() {
    updateToken()
  }
  
  func copyKeyButtonWasPressed() {
    UIPasteboard.general.string = publicKey
  }
  
  func logoutButtonWasPressed() {
    view?.setLogoutAlert()
  }
  
  func logoutOperationWasConfirmed() {
    ApplicationCoordinatorHelper.logout()
  }
  
  func helpButtonWasPressed() {
    let helpViewController = HelpViewController.createFromStoryboard()
    
    let publicKeyViewController = view as! PublicKeyViewController
    publicKeyViewController.navigationController?.pushViewController(helpViewController, animated: true)
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
