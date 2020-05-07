import Foundation
import UIKit

protocol VaultPublicKeyPresenter {
  var sections: [VaultPublicKeySection] { get }
  func vaultPublicKeyViewDidLoad()
  func nextButtonWasPressed()
  func copyKeyButtonWasPressed()
  func showQRCodeButtonWasPressed()
  func actionButtonWasPressed()
  func helpButtonWasPressed()
}

protocol VaultPublicKeyView: class {
  func setProgressAnimation(isDisplay: Bool)
  func setPublicKeyPopover(_ popover: CustomPopoverViewController)
  func reloadTable()
}

class VaultPublicKeyPresenterImpl: VaultPublicKeyPresenter {
  private weak var view: VaultPublicKeyView?
  private let navigationController: UINavigationController
  private let mnemonicManager: MnemonicManager
  private let vaultStorage: VaultStorage
  private let transactionService: TransactionService
  private let notificationManager: NotificationManager
  private let lobstrChecker: LobstrChecker
  
  private var publicKey: String?
  
  var sections: [VaultPublicKeySection] = []
  
  // MARK: - Init
  
  init(view: VaultPublicKeyView,
       navigationController: UINavigationController,
       mnemonicManager: MnemonicManager = MnemonicManagerImpl(),
       transactionService: TransactionService = TransactionService(),
       notificationRegistrator: NotificationManager = NotificationManager(),
       vaultStorage: VaultStorage = VaultStorage(),
       lobstrChecker: LobstrChecker = LobstrCheckerImpl()) {
    self.view = view
    self.navigationController = navigationController
    self.mnemonicManager = mnemonicManager
    self.vaultStorage = vaultStorage
    self.transactionService = transactionService
    notificationManager = notificationRegistrator
    self.lobstrChecker = lobstrChecker
  }
  
  func vaultPublicKeyViewDidLoad() {
    createSections()
    registerForRemoteNotifications()
    
    UserDefaultsHelper.accountStatus = .waitingToBecomeSigner
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidChangeSignerDetails(_:)),
                                           name: .didChangeSignerDetails,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                            selector: #selector(onBecomeActive(_:)),
                                            name: UIApplication.didBecomeActiveNotification,
                                            object: nil)
  }
  
  func createSections() {
    guard let publicKey = vaultStorage.getPublicKeyFromKeychain() else { return }
    self.publicKey = publicKey
       
    let rows: [VaultPublicKeyRow] = [.usingLobstrWallet(lobstrChecker.checkLobstr()),
                                     .usingDifferentService(publicKey)]
       
    sections = [VaultPublicKeySection(type: .main, rows: rows)]
    view?.reloadTable()
  }
  
  @objc func onDidChangeSignerDetails(_ notification: Notification) {
    updateToken()
  }
  
  @objc func onBecomeActive(_ notification: Notification) {
    createSections()
  }
  
  func nextButtonWasPressed() {
    updateToken()
  }
  
  func actionButtonWasPressed() {
    switch lobstrChecker.checkLobstr() {
    case .installed:
      if let url = URL(string: Constants.lobstrMultisigScheme), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
      }
    case .notInstalled:
      if let url = URL(string: Constants.lobstrAppStoreLink) {
        UIApplication.shared.open(url)
      }
    }
  }
  
  func helpButtonWasPressed() {
    let helpViewController = HelpViewController.createFromStoryboard()
    
    let vaultViewController = view as! VaultPublicKeyViewController
    vaultViewController.navigationController?.pushViewController(helpViewController, animated: true)
  }
  
  func copyKeyButtonWasPressed() {
    UIPasteboard.general.string = publicKey ?? ""
  }
  
  func showQRCodeButtonWasPressed() {
    let publicKeyView = Bundle.main.loadNibNamed(PublicKeyPopover.nibName,
                                                 owner: view,
                                                 options: nil)?.first as! PublicKeyPopover
    publicKeyView.initData()
    
    let popoverHeight: CGFloat = 440
    let popover = CustomPopoverViewController(height: popoverHeight, view: publicKeyView)
    publicKeyView.popoverDelegate = popover
    
    view?.setPublicKeyPopover(popover)
  }
}

// MARK: - Private

extension VaultPublicKeyPresenterImpl {
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
        Logger.auth.error("Couldn't update token with error \(error)")
      }
    }
  }
  
  private func transitionToNextScreen() {
    transactionService.getSignedAccounts { result in
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
        Logger.auth.error("Couldn't get signed accounts with error \(error)")
      }
    }
  }
  
  private func registerForRemoteNotifications() {
    notificationManager.requestAuthorization { isGranted in
      UserDefaultsHelper.isNotificationsEnabled = isGranted
      self.notificationManager.sendFCMTokenToServer()
    }
  }
}

// MARK: - Navigation

extension VaultPublicKeyPresenterImpl {
  func transitionToRecheckScreen() {
    let recheckViewController = RecheckViewController.createFromStoryboard()
    
    guard let publicKeyViewController = view as? VaultPublicKeyViewController
    else { return }
    
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
