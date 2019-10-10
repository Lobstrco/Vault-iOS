import Foundation
import stellarsdk

class HomePresenterImpl: HomePresenter {
  
  private weak var view: HomeView?
  private let transactionService: TransactionService
  private let vaultStorage: VaultStorage
  
  private var publicKey: String?
  private var signerForKey: String?
  
  private let notificationManager: NotificationManager
  private let homeSectionsBuilder: HomeSectionsBuilder
  
  fileprivate var transactionNumberStatus: TaskStatus = .ready
  
  private lazy var sections: [HomeSection] =
    self.homeSectionsBuilder.buildSections()
  
  init(view: HomeView,
       transactionService: TransactionService = TransactionService(),
       notificationRegistrator: NotificationManager = NotificationManager(),
       vaultStorage: VaultStorage = VaultStorage(),
       homeSectionsBuilder: HomeSectionsBuilder = HomeSectionsBuilderImpl()) {
    self.view = view
    self.transactionService = transactionService
    self.vaultStorage = vaultStorage
    self.notificationManager = notificationRegistrator
    self.homeSectionsBuilder = homeSectionsBuilder
    
    addObservers()
  }
  
  @objc func onDidRemoveTransaction(_ notification: Notification) {
    displayTransactionNumber()
  }
  
  @objc func onDidChangeTransactionList(_ notification: Notification) {
    displayTransactionNumber()
  }
  
  @objc func onDidChangeSignerDetails(_ notification: Notification) {
    displayTransactionNumber()
    displaySignerDetails()
  }
  
  // MARK: - HomePresenter
  
  func homeViewDidLoad() {
    registerForRemoteNotifications()
    
    guard let viewController = view as? UIViewController else {
      return
    }
    
    view?.setSections(sections)
    
    if ConnectionHelper.checkConnection(viewController) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.displayTransactionNumber()
        self.displayPublicKey()
      }
    }
  }
  
  func homeViewDidAppear() {
    guard let viewController = view as? UIViewController else {
      return
    }
    
    if ConnectionHelper.checkConnection(viewController) {
      self.displaySignerDetails()
    }
  }
  
  func copyKeyButtonWasPressed() {
    if let publicKey = publicKey {
      UIPasteboard.general.string = publicKey
      view?.setCopyHUD()
    }
  }
  
  func copySignerKeyButtonWasPressed() {
    if let signerForKey = signerForKey {
      UIPasteboard.general.string = signerForKey
      view?.setCopyHUD()
    }
  }
  
  func updateSignerDetails() {
    displaySignerDetails()
  }
  
  // MARK: - Private
  
  private func addObservers() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidChangeTransactionList(_:)),
                                           name: .didChangeTransactionList,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidRemoveTransaction(_:)),
                                           name: .didRemoveTransaction,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidChangeSignerDetails(_:)),
                                           name: UIApplication.didBecomeActiveNotification,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidChangeSignerDetails(_:)),
                                           name: .didChangeSignerDetails,
                                           object: nil)
  }
  
  private func setStatus(_ status: TaskStatus) {
    transactionNumberStatus = status
    
    if status == .loading {
      view?.setProgressAnimationForTransactionNumber(isEnabled: true)
    } else {
      view?.setProgressAnimationForTransactionNumber(isEnabled: false)
    }
  }
  
  private func registerForRemoteNotifications() {
    notificationManager.requestAuthorization() { isGranted in
      UserDefaultsHelper.isNotificationsEnabled = isGranted
      self.notificationManager.sendFCMTokenToServer()
    }
  }
  
  // MARK: - HomeView
  
  func displayPublicKey() {
    guard let publicKeyFromKeychain = vaultStorage.getPublicKeyFromKeychain()
    else { return }
    view?.setPublicKey(publicKeyFromKeychain)
    publicKey = publicKeyFromKeychain
  }
  
  func displayTransactionNumber() {
    guard transactionNumberStatus == .ready else {
      return
    }
    
    setStatus(.loading)
    transactionService.getNumberOfTransactions() { result in
      switch result {
      case .success(let numberOfTransactions):
        let numberOfTransactions = String(numberOfTransactions)
        self.view?.setTransactionNumber(numberOfTransactions)
        self.setStatus(.ready)
      case .failure(let serverRequestError):
        self.setStatus(.ready)
        switch serverRequestError {
        case ServerRequestError.needRepeatRequest:          
          self.displayTransactionNumber()
        default:
          self.view?.setTransactionNumber("-")
        }
      }
    }
  }
  
  func displaySignerDetails() {
    transactionService.getSignedAccounts() { result in
      switch result {
      case .success(let signedAccounts):
        self.view?.setSignerDetails(signedAccounts)
        UserDefaultsHelper.numberOfSignerAccounts = signedAccounts.count
        
        if signedAccounts.count == 1 {
          self.signerForKey = signedAccounts.first?.address
        }
      case .failure(let serverRequestError):
        switch serverRequestError {
        case ServerRequestError.needRepeatRequest:
          self.displaySignerDetails()
        default:
          print("Something went wrong")
        }
      }
    }
  }
}
