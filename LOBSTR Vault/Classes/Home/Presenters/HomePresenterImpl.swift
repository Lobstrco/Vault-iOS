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
  var multiaccountPublicKeysCount: Int = 1
  var mainAccounts: [SignedAccount] = []
  
  private let notificationManager: NotificationManager
  private let homeSectionsBuilder: HomeSectionsBuilder
  
  private var transactionNumberStatus: TaskStatus = .ready
  
  lazy var sections: [HomeSection] = homeSectionsBuilder.buildSections()
  
  let storage: AccountsStorage = AccountsStorageDiskImpl()
  var storageAccounts: [SignedAccount] = []
      
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
  
  @objc func onDidAllJWTTokensGet(_ notification: Notification) {
    if UserDefaultsHelper.isNotificationsEnabled {
      notificationManager.requestAuthorization { isGranted in
        UserDefaultsHelper.isNotificationsEnabled = isGranted
        self.notificationManager.registerAllAccountsForRemoteNotifications()
      }
    }
  }
  
  @objc func onDidActivePublicKeyChange(_ notification: Notification) {
    setPublicKey()
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
    
    UtilityHelper.checkAllJWTTokens()
    
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
  
  func moreDetailsButtonWasPressed(for publicKey: String, type: NicknameDialogType) {
    switch type {
    case .primaryAccount:
      if let index = mainAccounts.firstIndex(where: { $0.address == publicKey }) {
        var isNicknameSet = false
        if let nickname = mainAccounts[index].nickname, !nickname.isEmpty {
          isNicknameSet = true
        } else {
          isNicknameSet = false
        }
        self.view?.actionSheetForAccountsListWasPressed(isNicknameSet: isNicknameSet)
      }
    case .protectedAccount:
      if let index = signedAccounts.firstIndex(where: { $0.address == publicKey }) {
        var isNicknameSet = false
        if let nickname = signedAccounts[index].nickname, !nickname.isEmpty {
          isNicknameSet = true
        } else {
          isNicknameSet = false
        }
        self.view?.actionSheetForSignersListWasPressed(with: publicKey, isNicknameSet: isNicknameSet)
      }
    }
  }
  
  func copySignerPublicKeyActionWasPressed(_ publicKey: String) {
    UIPasteboard.general.string = publicKey
    Logger.home.debug("Public key was copied: \(publicKey)")
    view?.setCopyHUD()
  }
  
  func explorerSignerAccountActionWasPressed(_ publicKey: String) {
    UtilityHelper.openStellarExpertForPublicKey(publicKey: publicKey)
  }
  
  func setNicknameActionWasPressed(with text: String?, for publicKey: String?, nicknameDialogType: NicknameDialogType?) {
    guard let type = nicknameDialogType else { return }
    guard let publicKey = publicKey else { return }
    
    var allAccounts: [SignedAccount] = []
    allAccounts.append(contentsOf: mainAccounts)
    allAccounts.append(contentsOf: AccountsStorageHelper.allSignedAccounts)
    
    if let index = allAccounts.firstIndex(where: { $0.address == publicKey }), let nickname = text {
      allAccounts[index].nickname = nickname
      storage.save(accounts: allAccounts)
      
      switch type {
      case .protectedAccount:
        NotificationCenter.default.post(name: .didNicknameSet, object: nil)
        self.view?.setSignedAccountsList(self.signedAccounts)
      case .primaryAccount:
        setPublicKey()
        //NotificationCenter.default.post(name: .didNicknameSet, object: nil)
      }
    }
  }
  
  func clearNicknameActionWasPressed(_ publicKey: String, nicknameDialogType: NicknameDialogType?) {
    setNicknameActionWasPressed(with: "", for: publicKey, nicknameDialogType: nicknameDialogType)
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
  
  func changeActiveAccount() {
    UtilityHelper.jwtTokenUpdate()
    self.setPublicKey()
  }
}

// MARK: - Private

private extension HomePresenterImpl {
  
  func stopRotate() {
    self.view?.rotateRefreshButton(isRotating: true)
  }
  
  func setSignerDetails() {
    self.storageAccounts = storage.retrieveAccounts() ?? []
    transactionService.getSignedAccounts() { result in
      switch result {
      case .success(let accounts):
        Logger.home.debug("Signed accounts were loaded with data: \(accounts)")
        self.signedAccounts = self.getSignedAccountsFromCache(accounts)
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
    
  func getSignedAccountsFromCache(_ signedAccounts: [SignedAccount]) -> [SignedAccount] {
    var newAccounts : [SignedAccount] = []
    for (index, signedAccount) in signedAccounts.enumerated() {
      guard let address = signedAccount.address else { break }
      
      if let account = storageAccounts.first(where: { $0.address == address }) {
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
    AccountsStorageHelper.updateAllSignedAccounts(signedAccounts: newAccounts)
    return newAccounts
  }
  
  func tryToLoadFederation(by publicKey: String, for index: Int) {
    federationService.getFederation(for: publicKey) { result in
      switch result {
      case .success(let account):
        self.signedAccounts[index].federation = account.federation
        AccountsStorageHelper.updateAllSignedAccounts(signedAccounts: self.signedAccounts)
        self.view?.setSignedAccountsList(self.signedAccounts)
      case .failure(let error):
        Logger.home.error("Couldn't get federation for \(publicKey) with error: \(error)")
      }
    }
  }
  
  func setPublicKey() {
    mainAccounts = AccountsStorageHelper.getMainAccountsFromCache()
    guard let publicKeysFromKeychain = vaultStorage.getPublicKeysFromKeychain() else {
      guard let publicKeyFromKeychain = vaultStorage.getPublicKeyFromKeychain() else { return }
      ActivePublicKeyHelper.storeInKeychain(publicKeyFromKeychain)
      UserDefaultsHelper.activePublicKey = publicKeyFromKeychain
      UserDefaultsHelper.activePublicKeyIndex = 0
      publicKey = publicKeyFromKeychain
      multiaccountPublicKeysCount = 1
      let nickname = AccountsStorageHelper.getActiveAccountNickname()
      view?.setPublicKey(publicKeyFromKeychain.getTruncatedPublicKey(), nickname)
      view?.setIconCardOrIdenticon()
      return
    }
    
    guard let index = publicKeysFromKeychain.firstIndex(of: UserDefaultsHelper.activePublicKey) else { return }
    let publicKeyFromKeychain = publicKeysFromKeychain[index]
    ActivePublicKeyHelper.storeInKeychain(publicKeyFromKeychain)
    publicKey = publicKeyFromKeychain
    multiaccountPublicKeysCount = publicKeysFromKeychain.count
    let nickname = AccountsStorageHelper.getActiveAccountNickname()
    view?.setPublicKey(publicKeyFromKeychain.getTruncatedPublicKey(), nickname)
    view?.setIconCardOrIdenticon()
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
    // Multiaccount support case
    if !UserDefaultsHelper.pushNotificationsStatuses.isEmpty {
      if NotificationsStatusesHelper.isNotificationsEnabled {
        notificationManager.requestAuthorization() { isGranted in
          self.notificationManager.sendFCMTokenToServer()
        }
      }
    } else {
      if UserDefaultsHelper.isNotificationsEnabled {
        notificationManager.requestAuthorization() { isGranted in
          UserDefaultsHelper.isNotificationsEnabled = isGranted
          self.notificationManager.sendFCMTokenToServer()
        }
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
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidAllJWTTokensGet(_:)),
                                           name: .didAllJWTTokensGet,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidActivePublicKeyChange(_:)),
                                           name: .didActivePublicKeyChange,
                                           object: nil)
   }
}
