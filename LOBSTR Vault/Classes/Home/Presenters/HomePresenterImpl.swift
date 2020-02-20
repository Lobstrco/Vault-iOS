import Foundation
import stellarsdk

class HomePresenterImpl: HomePresenter {
  
  private weak var view: HomeView?
  private let transactionService: TransactionService
  private let federationService: FederationService
  private let vaultStorage: VaultStorage
  
  private var publicKey: String?
  private var signedAccounts: [SignedAccount] = []
  
  private let notificationManager: NotificationManager
  private let homeSectionsBuilder: HomeSectionsBuilder
  
  fileprivate var transactionNumberStatus: TaskStatus = .ready
  
  lazy var sections: [HomeSection] = homeSectionsBuilder.buildSections()
  
  init(view: HomeView,
       transactionService: TransactionService = TransactionService(),
       federationService: FederationService = FederationService(),
       notificationRegistrator: NotificationManager = NotificationManager(),
       vaultStorage: VaultStorage = VaultStorage(),
       homeSectionsBuilder: HomeSectionsBuilder = HomeSectionsBuilderImpl()) {
    self.view = view
    self.transactionService = transactionService
    self.federationService = federationService
    self.vaultStorage = vaultStorage
    self.notificationManager = notificationRegistrator
    self.homeSectionsBuilder = homeSectionsBuilder
    
    addObservers()
  }
  
  @objc func onDidRemoveTransaction(_ notification: Notification) {
    setTransactionNumber()
  }
  
  @objc func onDidChangeTransactionList(_ notification: Notification) {
    setTransactionNumber()
  }
  
  @objc func onDidChangeSignerDetails(_ notification: Notification) {
    setTransactionNumber()
    setSignerDetails()
  }
  
  // MARK: - HomePresenter
  
  func homeViewDidLoad() {
    registerForRemoteNotifications()
    
    guard let viewController = view as? UIViewController else {
      return
    }
    
    if ConnectionHelper.checkConnection(viewController) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.setTransactionNumber()
        self.setPublicKey()
        self.setSignerDetails()
      }
    }
  }
  
  func copyKeyButtonWasPressed() {
    if let publicKey = publicKey {
      UIPasteboard.general.string = publicKey
      view?.setCopyHUD()
    }
  }
  
  func copySignerPublicKeyActionWasPressed(with index: Int) {
    let publicKey = signedAccounts[safe: index]?.address ?? "uknown public key"
    UIPasteboard.general.string = publicKey
    Logger.home.debug("Public key was copied: \(publicKey)")
    view?.setCopyHUD()
  }
  
  func explorerSignerAccountActionWasPressed(with index: Int) {
    guard let address = signedAccounts[safe: index]?.address else {
      Logger.home.error("Couldn't open stellar expert. Signers list is empty")
      return
    }
    
    UtilityHelper.openStellarExpert(for: address)
  }
  
  func updateSignerDetails() {
    setSignerDetails()
  }
  
  func refreshButtonWasPressed() {
    self.setTransactionNumber()
    self.setPublicKey()
    self.setSignerDetails()
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
  
  func setPublicKey() {
    guard let publicKeyFromKeychain = vaultStorage.getPublicKeyFromKeychain()
    else { return }
    sections[HomeSectionType.vaultPublicKey.index].rows = [.publicKey(publicKeyFromKeychain)]
    publicKey = publicKeyFromKeychain
    
    view?.reloadTableViewSections([HomeSectionType.vaultPublicKey.index])
  }
  
  func setTransactionNumber() {
    guard transactionNumberStatus == .ready else {
      return
    }
    
    setStatus(.loading)
    transactionService.getNumberOfTransactions() { result in
      self.setStatus(.ready)
      switch result {
      case .success(let numberOfTransactions):
        self.sections[HomeSectionType.transactionsToSign.index].rows = [.numberOfTransactions(String(numberOfTransactions))]
        self.view?.reloadTableViewSections([HomeSectionType.transactionsToSign.index])
        self.notificationManager.setNotificationBadge(badgeNumber: numberOfTransactions)
      case .failure(let serverRequestError):
        switch serverRequestError {
        case ServerRequestError.needRepeatRequest:          
          self.setTransactionNumber()
        default:
          self.sections[HomeSectionType.transactionsToSign.index].rows = [.numberOfTransactions("-")]
          self.view?.reloadTableViewSections([HomeSectionType.transactionsToSign.index])
        }
      }
    }
  }
  
  func setSignerDetails() {
    transactionService.getSignedAccounts() { result in
      switch result {
      case .success(let accounts):
        Logger.home.debug("Signed accounts were loaded with data: \(accounts)")
        self.signedAccounts = self.getAccountsFromCache(accounts)
        self.sections[HomeSectionType.signersTotalNumber.index].rows = [.totalNumber(self.signedAccounts.count)]
        self.sections[HomeSectionType.listOfSigners.index].rows = self.signedAccounts.map { .signer($0) }
        
        self.view?.reloadTableViewSections([HomeSectionType.signersTotalNumber.index,
                                            HomeSectionType.listOfSigners.index])
        UserDefaultsHelper.numberOfSignerAccounts = self.signedAccounts.count
      case .failure(let serverRequestError):
        switch serverRequestError {
        case ServerRequestError.needRepeatRequest:
          self.setSignerDetails()
        default:
          Logger.home.error("Couldn't get signed accounts")
        }
      }
    }
  }
  
  func getAccountsFromCache(_ signedAccounts: [SignedAccount]) -> [SignedAccount] {
    var newAccounts : [SignedAccount] = []
    for (index, signedAccount) in signedAccounts.enumerated() {
      guard let address = signedAccount.address else { break }
      if let account = CoreDataStack.shared.fetch(Account.fetchBy(publicKey: address)).first {
        newAccounts.append(SignedAccount(address: account.publicKey, federation: account.federation))
      } else {
        newAccounts.append(SignedAccount(address: address, federation: nil))
        tryToLoadFederation(by: address, for: index)
      }
    }
    
    return newAccounts
  }
  
  func tryToLoadFederation(by publicKey: String, for index: Int) {
    federationService.getFederation(for: publicKey) { result in
      switch result {
      case .success(let account):
        if let _ = self.sections[safe: HomeSectionType.listOfSigners.index] {
          self.sections[HomeSectionType.listOfSigners.index].rows[index] =
            .signer(SignedAccount(address: account.publicKey, federation: account.federation))
        }
        self.view?.reloadSignerListRow(index)
      case .failure(let error):
        Logger.home.error("Couldn't get federation for \(publicKey) with error: \(error)")
      }
    }
  }
}
