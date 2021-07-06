import Foundation
import stellarsdk

class HomePresenterImpl: HomePresenter {
  
  private weak var view: HomeView?
  private let transactionService: TransactionService
  private let versionControlService: VersionControlService
  private let federationService: FederationService
  private let vaultStorage: VaultStorage
  
  var publicKey: String?
  var signedAccounts: [SignedAccount] = []
  
  private let notificationManager: NotificationManager
  private let homeSectionsBuilder: HomeSectionsBuilder
  
  private var transactionNumberStatus: TaskStatus = .ready
  
  lazy var sections: [HomeSection] = homeSectionsBuilder.buildSections()
  
  let storage: SignersStorage = SignersStorageDiskImpl()
  var storageSigners: [SignedAccount] = []
    
  init(view: HomeView,
       transactionService: TransactionService = TransactionService(),
       versionControlService: VersionControlService = VersionControlService(),
       federationService: FederationService = FederationService(),
       notificationRegistrator: NotificationManager = NotificationManager(),
       vaultStorage: VaultStorage = VaultStorage(),
       homeSectionsBuilder: HomeSectionsBuilder = HomeSectionsBuilderImpl()) {
    self.view = view
    self.transactionService = transactionService
    self.versionControlService = versionControlService
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
    switch UserDefaultsHelper.accountStatus {
    case .createdWithTangem:
      if VersionControlHelper.checkIfAlertViewHasPresented() == nil {
        VersionControlHelper.checkAppVersion(showAlertImmediately: false) { versions in
          let compare = versions["min_app_version"]?.compare(VersionControlHelper.currentAppVersion, options: .numeric)
          if compare == .orderedDescending {
            VersionControlHelper.showForceUpdate()
          }
        }
      }
    default:
      break
    }
    setTransactionNumber()
    setSignerDetails()
  }
  
  @objc func onDidJWTTokenUpdate(_ notification: Notification) {
    setTransactionNumber()
    setSignerDetails()
    registerForRemoteNotifications()
  }
  
  @objc func checkControlVersion(_ notification: Notification) {
    VersionControlHelper.checkAppVersion(showAlertImmediately: true, completion: {_ in })
  }
  
  @objc func onDidNicknameUpdate(_ notification: Notification) {
    setSignerDetails()
  }
  
  // MARK: - HomePresenter
  func homeViewDidAppear() {
    guard let viewController = view as? UIViewController else { return }
    guard UtilityHelper.isTokenUpdated(view: viewController) else { return }
  }
  
  func homeViewDidLoad() {
    switch UserDefaultsHelper.accountStatus {
    case .createdWithTangem:
      if VersionControlHelper.checkIfAlertViewHasPresented() == nil {
        VersionControlHelper.checkAppVersion(showAlertImmediately: true, completion: {_ in })
      }
    default:
      break
    }

    setPublicKey()
    guard let viewController = view as? UIViewController else { return }
    registerForRemoteNotifications()
    
    if ConnectionHelper.checkConnection(viewController) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.setTransactionNumber()
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
  
  func moreDetailsButtonWasPressed(with index: Int) {
    guard let address = signedAccounts[safe: index]?.address else {
      return
    }
    
    if let index = signedAccounts.firstIndex(where: { $0.address == address }) {
      var isNicknameSet = false
      if let nickname = signedAccounts[index].nickname, !nickname.isEmpty {
        isNicknameSet = true
      } else {
        isNicknameSet = false
      }
      self.view?.actionSheetForSignersListWasPressed(with: index, isNicknameSet: isNicknameSet)
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
    
    UtilityHelper.openStellarExpertForPublicKey(publicKey: address)
  }
  
  func setAccountNicknameActionWasPressed(with text: String?, by index: Int?) {
    guard let index = index, let address = signedAccounts[safe: index]?.address else {
      return
    }
    
    if let index = signedAccounts.firstIndex(where: { $0.address == address }), let nickname = text {
      signedAccounts[index].nickname = nickname
      storage.save(signers: signedAccounts)
      NotificationCenter.default.post(name: .didNicknameSet, object: nil)
      self.view?.setSignedAccountsList(self.signedAccounts)
    }
  }
  
  func clearAccountNicknameActionWasPressed(by index: Int?) {
    setAccountNicknameActionWasPressed(with: "", by: index)
  }
  
  func updateSignerDetails() {
    setSignerDetails()
  }
  
  func refreshButtonWasPressed() {
    guard let viewController = view as? UIViewController else { return }
    guard UtilityHelper.isTokenUpdated(view: viewController) else { return }
    
    self.view?.rotateRefreshButton(isRotating: false)
    self.setTransactionNumber()
    self.setPublicKey()
    self.setSignerDetails()
  }
}

// MARK: - Private

private extension HomePresenterImpl {
  
  func stopRotate() {
    self.view?.rotateRefreshButton(isRotating: true)
  }
  
  func setSignerDetails() {
    self.storageSigners = storage.retrieveSigners() ?? []
    transactionService.getSignedAccounts() { result in
      switch result {
      case .success(let accounts):
        Logger.home.debug("Signed accounts were loaded with data: \(accounts)")
        self.signedAccounts = self.getAccountsFromCache(accounts)
        UserDefaultsHelper.numberOfSignerAccounts = self.signedAccounts.count
        
        self.view?.setNumberOfSignedAccount(self.signedAccounts.count)
        self.view?.setAccountLabel()
        self.view?.setSignedAccountsList(self.signedAccounts)
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
      
      if let account = storageSigners.first(where: { $0.address == address }) {
        newAccounts.append(SignedAccount(address: account.address, federation: account.federation, nickname: account.nickname))
      } else {
        if let account = CoreDataStack.shared.fetch(Account.fetchBy(publicKey: address)).first {
          newAccounts.append(SignedAccount(address: account.publicKey, federation: account.federation, nickname: ""))
        } else {
          newAccounts.append(SignedAccount(address: address, federation: nil))
          tryToLoadFederation(by: address, for: index)
        }
      }
    }
    
    return newAccounts
  }
  
  func tryToLoadFederation(by publicKey: String, for index: Int) {
    federationService.getFederation(for: publicKey) { result in
      switch result {
      case .success(let account):
        self.signedAccounts[index].federation = account.federation
        self.view?.setSignedAccountsList(self.signedAccounts)
      case .failure(let error):
        Logger.home.error("Couldn't get federation for \(publicKey) with error: \(error)")
      }
    }
  }
  
  func setPublicKey() {
    guard let publicKeyFromKeychain = vaultStorage.getPublicKeyFromKeychain() else { return }
    publicKey = publicKeyFromKeychain
    view?.setPublicKey(publicKeyFromKeychain.getTruncatedPublicKey())
  }
    
  func setTransactionNumber() {
    guard transactionNumberStatus == .ready else {
      return
    }
    
    setStatus(.loading)
    transactionService.getNumberOfTransactions() { result in
      self.setStatus(.ready)
      self.stopRotate()
      switch result {
      case .success(let numberOfTransactions):
        self.view?.setTransactionNumber(numberOfTransactions.description)
        UserDefaultsHelper.badgesCounter = numberOfTransactions
      case .failure(let serverRequestError):
        self.view?.setTransactionNumber("-")
        Logger.home.error("Couldn't get number of transactions with error \(serverRequestError)" )
      }
    }
  }
  
  func setStatus(_ status: TaskStatus) {
    transactionNumberStatus = status
    
    if status == .loading {
      view?.setProgressAnimationForTransactionNumber()
    }
  }
  
  func registerForRemoteNotifications() {
    if UserDefaultsHelper.isNotificationsEnabled {
      notificationManager.requestAuthorization() { isGranted in
        UserDefaultsHelper.isNotificationsEnabled = isGranted
        self.notificationManager.sendFCMTokenToServer()
      }
    }
  }
  
  func addObservers() {
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

    NotificationCenter.default.addObserver(self,
                                          selector: #selector(onDidJWTTokenUpdate(_:)),
                                          name: .didJWTTokenUpdate,
                                          object: nil)
    
    NotificationCenter.default.addObserver(self,
                                          selector: #selector(checkControlVersion(_:)),
                                          name: .didPinScreenClose,
                                          object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidNicknameUpdate(_:)),
                                           name: .didNicknameSet,
                                           object: nil)
   }
}
