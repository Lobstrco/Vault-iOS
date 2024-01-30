import Foundation
import stellarsdk

class TransactionDetailsPresenterImpl {
  private weak var view: TransactionDetailsView?
  
  private weak var crashlyticsService: CrashlyticsService?
  private var transactionService: TransactionService
  private let federationService: FederationService
  private let vaultStorage: VaultStorage
  private var mnemonicManager: MnemonicManager
  private let sdk: StellarSDK
  
  private var indexInTransactionList: Int?
  private let transaction: Transaction
  
  private lazy var xdr: String = {
    guard let transactionXDR = transaction.xdr else {
      fatalError()
    }
    return transactionXDR
  }()
  
  var transactionListIndex: Int? {
    get { return indexInTransactionList }
    set { indexInTransactionList = newValue }
  }
  
  var numberOfOperation: Int {
    return operations.count
  }
  
  var numberOfAcceptedSignatures: Int {
    return signers
      .filter { $0.status == .accepted }
      .count
  }
  
  var numberOfNeededSignatures: Int = 0

  var isNeedToShowHelpfulMessage: Bool = false
  var isNeedToShowSignaturesNumber: Bool = true
  
  var isVaultAccountPending: Bool {
    if signers.first(where: { $0.publicKey == UserDefaultsHelper.activePublicKey})?.status == .pending {
      return true
    } else {
      return false
    }
  }
  
  private let transactionType: TransactionType
  private var operations: [String] = []
  private var signers: [SignerViewData] = []
  private var operationDetails: [(name: String, value: String, nickname: String, isPublicKey: Bool, isAssetCode: Bool)] = []
  private var destinationFederation: String = ""
  private var isDownloading: Bool = false
  private var assets: [stellarsdk.Asset] = []
  private var publicKeys: [String] = []
  private var txSourceAccountId = ""
  private var txSequenceNumber = 0
  private var isAfterPushNotification: Bool
  private var accountSequenceNumber = 0
  
  var sections = [TransactionDetailsSection]()
  
  private let storage: AccountsStorage = AccountsStorageDiskImpl()
  var storageAccounts: [SignedAccount] = []
  
  // MARK: - Init

  init(view: TransactionDetailsView,
       transaction: Transaction,
       type: TransactionType,
       isAfterPushNotification: Bool,
       crashlyticsService: CrashlyticsService = CrashlyticsService(),
       transactionService: TransactionService = TransactionService(),
       federationService: FederationService = FederationService(),
       vaultStorage: VaultStorage = VaultStorage(),
       mnemonicManager: MnemonicManager = MnemonicManagerImpl(),
       sdk: StellarSDK = StellarSDK(withHorizonUrl: Environment.horizonBaseURL))
  {
    self.view = view
    self.crashlyticsService = crashlyticsService
    self.transactionService = transactionService
    self.federationService = federationService
    self.mnemonicManager = mnemonicManager
    self.transaction = transaction
    self.transactionType = type
    self.sdk = sdk
    self.vaultStorage = vaultStorage
    self.isAfterPushNotification = isAfterPushNotification
    addObservers()
  }
  
  @objc func onDidJWTTokenUpdate(_ notification: Notification) {
    initialLoad()
  }
  
  @objc func updateProgressAnimation(_ notification: Notification) {
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) {
      self.view?.setProgressAnimation(isEnabled: self.isDownloading)
    }
  }
  
  @objc func onDidNicknameUpdate(_ notification: Notification) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.reloadData()
    }
  }
  
  @objc func onDidActivePublicKeyChange(_ notification: Notification) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.reloadData()
    }
  }
  
  @objc func onDidSignCardScan(_ notification: Notification) {
    view?.setButtons(isEnabled: false)
    if let topVC = UIApplication.getTopViewController() {
      if (topVC is TransactionDetailsViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
          self.view?.setProgressAnimation(isEnabled: true)
        }
      }
    }
  }
}

// MARK: - TransactionDetailsPresenter

extension TransactionDetailsPresenterImpl: TransactionDetailsPresenter {
  func transactionDetailsViewDidLoad() {
    registerTableViewCell()
    initialLoad()
  }
  
  func initialLoad() {
    guard let transactionEnvelopeXDR = try? TransactionEnvelopeXDR(xdr: xdr),
          let viewController = view as? UIViewController,
          UtilityHelper.isTokenUpdated(view: viewController) else { return }
    
    txSourceAccountId = transactionEnvelopeXDR.txSourceAccountId
    txSequenceNumber = Int(truncatingIfNeeded: transactionEnvelopeXDR.txSeqNum)
    view?.setProgressAnimation(isEnabled: true)
    isDownloading = true
    let destinationId = tryToGetDestinationId()
    
    if !destinationId.isEmpty {
      federationService.getFederation(for: destinationId) { result in
        switch result {
        case .success(let account):
          if let federation = account.federation {
            self.destinationFederation = federation
            self.tryToGetSignedAccounts(transactionEnvelopeXDR: transactionEnvelopeXDR)
          } else {
            self.tryToGetSignedAccounts(transactionEnvelopeXDR: transactionEnvelopeXDR)
          }
        case .failure(let error):
          self.tryToGetSignedAccounts(transactionEnvelopeXDR: transactionEnvelopeXDR)
          Logger.home.error("Couldn't get federation for \(destinationId) with error: \(error)")
        }
      }
    } else {
      tryToGetSignedAccounts(transactionEnvelopeXDR: transactionEnvelopeXDR)
    }
  }
  
  func setData() {
    setOperationList()
    setOperationDetails()
    sections = buildSections()
    setTitle()
    view?.reloadData()
  }
  
  func operationWasSelected(by index: Int) {
    do {
      let operation = try TransactionHelper.getOperation(from: xdr, by: index)
      transition(to: operation, by: index)
    } catch {
      crashlyticsService?.recordCustomException(error)
      view?.setErrorAlert(for: error)
    }
  }
  
  func publicKeyWasSelected(key: String?) {
    do {
      let operation = try TransactionHelper.getOperation(from: xdr)
      let publicKeys = TransactionHelper.getPublicKeys(from: operation)
      self.publicKeys.append(contentsOf: publicKeys)
      if let key = key, key.isShortStellarPublicAddress || key.isShortMuxedAddress {
        if let key = self.publicKeys.first(where: { $0.prefix(4) == key.prefix(4) && $0.suffix(4) == key.suffix(4) }) {
          TransactionHelper.isVaultSigner(publicKey: key) { result in
            self.view?.showActionSheet(key, .publicKey(isNicknameSet: false, isVaultSigner: result))
          }
        }
      } else {
        let secondPartOfKey = key?.suffix(14) ?? ""
        let shortPublicKey = TransactionHelper.getShortPublicKey(String(secondPartOfKey))
        if let nickname = key?.replacingOccurrences(of: secondPartOfKey, with: ""),
           let account = storageAccounts.first(where: { $0.nickname == nickname && $0.address?.prefix(4) == shortPublicKey.prefix(4) && $0.address?.suffix(4) == shortPublicKey.suffix(4) })
        {
          if let key = self.publicKeys.first(where: { $0.prefix(4) == account.address?.prefix(4) && $0.suffix(4) == account.address?.suffix(4) }) {
            TransactionHelper.isVaultSigner(publicKey: key) { result in
              self.view?.showActionSheet(key, .publicKey(isNicknameSet: !nickname.isEmpty, isVaultSigner: result))
            }
          }
        }
      }
    } catch {
      return
    }
  }
  
  func assetCodeWasSelected(code: String?) {
    if !self.assets.isEmpty {
      if let asset = assets.first(where: { $0.code == code }) {
        self.view?.showActionSheet(asset, .assetCode)
      } else {
        self.view?.showActionSheet(nil, .nativeAssetCode)
      }
    }
  }
  
  func confirmButtonWasPressed() {
    checkSequenceNumberCount { result in
      DispatchQueue.main.async {
        if result {
          guard UserDefaultsHelper.accountStatus == .createdByDefault else {
            self.confirmOperationWasConfirmed()
            return
          }
          
          if PromtForTransactionDecisionsHelper.isPromtTransactionDecisionsEnabled {
            self.setConfirmationAlert()
          } else {
            self.confirmOperationWasConfirmed()
          }
        } else {
          self.view?.setSequenceNumberCountAlert()
        }
      }
    }
  }
  
  func denyButtonWasPressed() {
    if PromtForTransactionDecisionsHelper.isPromtTransactionDecisionsEnabled {
      view?.setDenyingAlert()
    } else {
      denyOperationWasConfirmed()
    }
  }
  
  func denyOperationWasConfirmed() {
    switch transactionType {
    case .imported:
      openTransactionListScreen()
    case .standard:
      cancelTransaction()
    }
  }
  
  func confirmOperationWasConfirmed() {
    guard let viewController = view as? UIViewController else { return }
    guard ConnectionHelper.checkConnection(viewController) else { return }
    guard UtilityHelper.isTokenUpdated(view: viewController) else { return }
    
    if UserDefaultsHelper.accountStatus == .createdByDefault {
      view?.setProgressAnimation(isEnabled: true)
    }
    switch transactionType {
    case .imported:
      guard let transactionEnvelopeXDR = try? TransactionEnvelopeXDR(xdr: xdr) else {
        return
      }
      submitTransaction(transactionEnvelopeXDR, transactionType: self.transaction.transactionType ?? .transaction)
    case .standard:
      guard let hash = transaction.hash else {
        return
      }
      updateTransactionAndSend(by: hash)
    }
  }
  
  func copyXdr() {
    view?.copy(xdr)
  }
  
  func signedXdr() {
    guard let transactionEnvelopeXDR = try? TransactionEnvelopeXDR(xdr: xdr) else {
      return
    }
    signTransaction(transactionEnvelopeXDR)
  }
  
  func viewTransactionDetails() {
    UtilityHelper.openStellarLaboratory(for: xdr)
  }
  
  func copyPublicKey(_ key: String) {
    UIPasteboard.general.string = key
    Logger.home.debug("Public key was copied: \(key)")
    view?.copy(key)
  }
  
  func explorerPublicKey(_ key: String) {
    UtilityHelper.openStellarExpertForPublicKey(publicKey: key)
  }
  
  func explorerAsset(_ asset: stellarsdk.Asset) {
    if let assetCode = asset.code, let assetIssuer = asset.issuer?.accountId {
      UtilityHelper.openStellarExpertForAsset(assetCode: assetCode, assetIssuer: assetIssuer)
    }
  }
  
  func explorerNativeAsset() {
    UtilityHelper.openStellarExpertForNativeAsset()
  }
  
  func setNicknameActionWasPressed(with text: String?, for publicKey: String?, nicknameDialogType: NicknameDialogType?) {
    guard let type = nicknameDialogType else { return }
    guard let publicKey = publicKey else { return }
    
    var allAccounts: [SignedAccount] = []
    allAccounts.append(contentsOf: AccountsStorageHelper.getMainAccountsFromCache())
    allAccounts.append(contentsOf: AccountsStorageHelper.allSignedAccounts)
    allAccounts.append(contentsOf: AccountsStorageHelper.getAllOtherAccounts())
    
    if let index = allAccounts.firstIndex(where: { $0.address == publicKey }), let nickname = text {
      allAccounts[index].nickname = nickname
      savedToICloud(account: allAccounts[index])
    } else {
      let account = SignedAccount(address: publicKey, federation: nil, nickname: text, indicateAddress: AccountsStorageHelper.indicateAddress)
      allAccounts.append(account)
      savedToICloud(account: account)
    }
    
    storage.save(accounts: allAccounts)
    
    switch type {
    case .primaryAccount:
      NotificationCenter.default.post(name: .didActivePublicKeyChange, object: nil)
    default:
      NotificationCenter.default.post(name: .didNicknameSet, object: nil)
    }
    
    guard UIDevice.isConnectedToNetwork,
          let nickname = text,
          !nickname.isEmpty else { return }
    
    CloudKitNicknameHelper.checkIsICloudStatusAvaliable { isAvaliable in
      if isAvaliable {
        CloudKitNicknameHelper.isICloudDatabaseEmpty { result in
          if result, CloudKitNicknameHelper.isNeedToShowICloudSyncAdviceAlert {
            DispatchQueue.main.async {
              UserDefaultsHelper.isICloudSyncAdviceShown = true
              self.view?.showICloudSyncAdviceAlert()
            }
          }
        }
      }
    }
  }
  
  func clearNicknameActionWasPressed(_ publicKey: String, nicknameDialogType: NicknameDialogType?) {
    if UserDefaultsHelper.isICloudSynchronizationEnabled {
      guard UIDevice.isConnectedToNetwork else {
        view?.showNoInternetConnectionAlert()
        return
      }
      setNicknameActionWasPressed(with: "", for: publicKey, nicknameDialogType: nicknameDialogType)
    } else {
      setNicknameActionWasPressed(with: "", for: publicKey, nicknameDialogType: nicknameDialogType)
    }
  }
  
  func signerWasSelected(_ viewData: SignerViewData?) {
    guard let viewData = viewData else { return }
    let nickname = viewData.nickname ?? ""
    let type: NicknameDialogType = viewData.publicKey == UserDefaultsHelper.activePublicKey ? .primaryAccount : .protectedAccount
    TransactionHelper.isVaultSigner(publicKey: viewData.publicKey) { result in
      self.view?.showActionSheet(viewData.publicKey, .publicKey(isNicknameSet: !nickname.isEmpty, type: type, isVaultSigner: result))
    }
  }
  
  func proceedICloudSyncActionWasPressed() {
    view?.showICloudSyncScreen()
  }
}

// MARK: - Private

private extension TransactionDetailsPresenterImpl {
  func buildAdditionalInformationSection() -> [(name: String, value: String, nickname: String, isPublicKey: Bool)] {
    var additionalInformationSection: [(name: String, value: String, nickname: String, isPublicKey: Bool)] = []
        
    if let transactionXDR = try? TransactionEnvelopeXDR(xdr: xdr) {
      let memo = getMemo()
      
      if !memo.value.isEmpty {
        additionalInformationSection.append((name: memo.title, value: memo.value, nickname: "", isPublicKey: false))
      }
      
      additionalInformationSection.append((name: "Transaction Source", value: transactionXDR.txSourceAccountId.getTruncatedPublicKey(numberOfCharacters: TransactionHelper.numberOfCharacters), nickname: TransactionHelper.tryToGetNickname(publicKey: transactionXDR.txSourceAccountId), true))
      publicKeys.append(transactionXDR.txSourceAccountId)
      
      if let maxFee = getMaxFee(transactionXDR: transactionXDR) {
        additionalInformationSection.append((name: "Max Network Fee", value: maxFee + " XLM", nickname: "", isPublicKey: false))
      }
    }
    
    if let transactionDate = transaction.addedAt {
      additionalInformationSection.append((name: "Created", value: TransactionHelper.getValidatedDate(from: transactionDate), nickname: "", isPublicKey: false))
    }
    
    return additionalInformationSection
  }
  
  func getMaxFee(transactionXDR: TransactionEnvelopeXDR) -> String? {
    let oneStroop = Decimal(0.0000001)
    let maxFeeString = transactionXDR.txFee != 0 ? NSDecimalNumber(decimal:(oneStroop * Decimal(transactionXDR.txFee))).stringValue : nil
    return maxFeeString
  }
  
  func buildSections() -> [TransactionDetailsSection] {
    var listOfSections = [TransactionDetailsSection]()
    
    let operationsSection = TransactionDetailsSection(type: .operations, rows: operations.map { .operation($0) })
    let additionalInformationSection = TransactionDetailsSection(type: .additionalInformation, rows: buildAdditionalInformationSection().map { .additionalInformation($0) })
    let operationDetailsSection = TransactionDetailsSection(type: .operationDetails, rows: operationDetails.map { .operationDetail($0) })
    let signersSection = TransactionDetailsSection(type: .signers, rows: signers.map { .signer($0) })
    
    listOfSections.append(contentsOf: [additionalInformationSection])
    
    if operationsSection.rows.count > 1 {
      listOfSections.append(operationsSection)
    } else {
      listOfSections.append(operationDetailsSection)
    }
    
    if !signersSection.rows.isEmpty {
      listOfSections.append(signersSection)
    }
    return listOfSections
  }
  
  func setOperationList() {
    do {
      guard let transactionXDR = try? TransactionEnvelopeXDR(xdr: xdr) else {
        throw VaultError.TransactionError.invalidTransaction
      }
      operations = try TransactionHelper.getListOfOperationNames(from: transactionXDR, transactionType: transaction.transactionType)
    } catch {
      crashlyticsService?.recordCustomException(error)
      view?.setErrorAlert(for: error)
      return
    }
  }
  
  func setOperationDetails() {
    guard operations.count == 1 else { return }
    do {
      if let transactionXDR = try? TransactionEnvelopeXDR(xdr: xdr) {
        let operation = try TransactionHelper.getOperation(from: xdr)
        operationDetails = TransactionHelper.parseOperation(from: operation, transactionSourceAccountId: transactionXDR.txSourceAccountId, isListOperations: true, destinationFederation: self.destinationFederation)
        assets = TransactionHelper.getAssets(from: operation)
      }
    } catch {
      crashlyticsService?.recordCustomException(error)
      view?.setErrorAlert(for: error)
      return
    }
  }
  
  func setTitle() {
    var title = L10n.navTitleTransactionDetails
    
    if operations.count == 1, let operationName = operations.first {
      title = operationName
    }
    
    view?.setTitle(title)
  }
  
  func registerTableViewCell() {
    view?.registerTableViewCell(with: OperationDetailsTableViewCell.reuseIdentifier)
    view?.registerTableViewCell(with: OperationTableViewCell.reuseIdentifier)
    view?.registerTableViewCell(with: SignerTableViewCell.reuseIdentifier)
  }
  
  func openTransactionListScreen() {
    view?.openTransactionListScreen()
  }
  
  func cancelTransaction() {
    guard let viewController = view as? UIViewController else { return }
    guard ConnectionHelper.checkConnection(viewController) else { return }
    guard UtilityHelper.isTokenUpdated(view: viewController) else { return }
    
    guard let transactionHash = transaction.hash else {
      let error = VaultError.TransactionError.invalidTransaction
      view?.setErrorAlert(for: error)
      return
    }
    
    guard let transactionIndex = indexInTransactionList else {
      let error = VaultError.TransactionError.invalidTransaction
      view?.setErrorAlert(for: error)
      return
    }
    
    view?.setProgressAnimation(isEnabled: true)
    
    transactionService.cancelTransaction(by: transactionHash) { result in
      switch result {
      case .success:
        DispatchQueue.main.async {
          NotificationCenter.default.post(name: .didRemoveTransaction,
                                          object: nil,
                                          userInfo: ["transactionIndex": transactionIndex])
          self.transitionToTransactionListScreen()
          self.view?.setProgressAnimation(isEnabled: false)
        }
      case .failure(let error):
        DispatchQueue.main.async {
          self.view?.setProgressAnimation(isEnabled: false)
          if let serverRequestError = error as? ServerRequestError {
            switch serverRequestError {
            case .notFound:
              self.view?.showAlert(text: L10n.errorTransactionAlreadyConfirmedOrDeniedMessage)
            default:
              self.view?.setErrorAlert(for: serverRequestError)
            }
          } else {
            self.view?.showAlert(text: L10n.errorTransactionAlreadyConfirmedOrDeniedMessage)
          }
        }
      }
    }
  }
  
  func signTransaction(_ transactionEnvelopeXDR: TransactionEnvelopeXDR) {
    let gettingMnemonic = GettingMnemonicOperation()
    let signTransaction = SignTransactionOperation(transactionEnvelopeXDR: transactionEnvelopeXDR)
    let signTransactionWithTangem = SignTransactionWithTangemOperation(transactionEnvelopeXDR: transactionEnvelopeXDR)
    
    var operations: [AsyncOperation] = []
    
    switch UserDefaultsHelper.accountStatus {
    case .createdByDefault:
      signTransaction.addDependency(gettingMnemonic)
      operations.append(contentsOf: [gettingMnemonic, signTransaction])
    case .createdWithTangem:
      operations.append(contentsOf: [signTransactionWithTangem])
    default:
      view?.setProgressAnimation(isEnabled: false)
      return
    }
        
    OperationQueue().addOperations(operations, waitUntilFinished: false)
    
    signTransaction.completionBlock = {
      DispatchQueue.main.async {
        if let signed = signTransaction.xdrEnvelope {
          self.view?.copy(signed)
        }
      }
    }
    
    signTransactionWithTangem.completionBlock = {
      DispatchQueue.main.async { [self] in
        if let signed = signTransactionWithTangem.xdrEnvelope {
          self.view?.copy(signed)
        }
      }
    }
  }
  
  func submitTransaction(_ transactionEnvelopeXDR: TransactionEnvelopeXDR, transactionType: ServerTransactionType = .transaction) {
    let gettingMnemonic = GettingMnemonicOperation()
    let signTransaction = SignTransactionOperation(transactionEnvelopeXDR: transactionEnvelopeXDR)
    let signTransactionWithTangem = SignTransactionWithTangemOperation(transactionEnvelopeXDR: transactionEnvelopeXDR)
    let submitTransactionToHorizon = SubmitTransactionToHorizonOperation()
    let submitTransactionToVaultServer = SubmitTransactionToVaultServerOperation(transactionType: transactionType)
    
    var operations: [AsyncOperation] = [submitTransactionToVaultServer]
      
    switch UserDefaultsHelper.accountStatus {
    case .createdByDefault:
      signTransaction.addDependency(gettingMnemonic)
      if transactionType == .transaction {
        operations.append(submitTransactionToHorizon)
        submitTransactionToHorizon.addDependency(signTransaction)
        submitTransactionToVaultServer.addDependency(submitTransactionToHorizon)
      } else {
        submitTransactionToVaultServer.addDependency(signTransaction)
      }
      operations.append(contentsOf: [gettingMnemonic, signTransaction])
    case .createdWithTangem:
      if transactionType == .transaction {
        operations.append(submitTransactionToHorizon)
        submitTransactionToHorizon.addDependency(signTransactionWithTangem)
        submitTransactionToVaultServer.addDependency(submitTransactionToHorizon)
      } else {
        submitTransactionToVaultServer.addDependency(signTransactionWithTangem)
      }
      operations.append(contentsOf: [signTransactionWithTangem])
    default:
      view?.setProgressAnimation(isEnabled: false)
      return
    }
    
    OperationQueue().addOperations(operations, waitUntilFinished: false)
    
    submitTransactionToHorizon.completionBlock = {
      DispatchQueue.main.async {
        self.view?.setProgressAnimation(isEnabled: false)
        if let infoError = submitTransactionToHorizon.outputError as? ErrorDisplayable {
          self.view?.setErrorAlert(for: infoError)
          self.view?.setButtons(isEnabled: true)
          return
        }
        guard let horizonResult = submitTransactionToHorizon.horizonResult else { return }
        let xdr = self.getOutputXdr(signTransaction: signTransaction, signTransactionWithTangem: signTransactionWithTangem)
        self.transitionToTransactionStatus(with: horizonResult, xdr: xdr, transactionType: nil, transactionHash: submitTransactionToHorizon.transactionHash)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
          NotificationCenter.default.post(name: .didChangeTransactionList, object: nil)
        }
      }
    }
    
    submitTransactionToVaultServer.completionBlock = {
      DispatchQueue.main.async {
        self.view?.setProgressAnimation(isEnabled: false)
        if let _ = submitTransactionToVaultServer.outputError {
          return
        }
        
        if transactionType == .authChallenge {
          let xdr = self.getOutputXdr(signTransaction: signTransaction, signTransactionWithTangem: signTransactionWithTangem)
          self.transitionToTransactionStatus(with: (TransactionResultCode.badAuth, operationMessageError: nil), xdr: xdr, transactionType: .authChallenge, transactionHash: nil)
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NotificationCenter.default.post(name: .didChangeTransactionList, object: nil)
          }
        }
      }
    }
  }
  
  func getOutputXdr(signTransaction: SignTransactionOperation, signTransactionWithTangem: SignTransactionWithTangemOperation) -> String {
    var outputXdr = ""
    switch UserDefaultsHelper.accountStatus {
    case .createdByDefault:
      guard let xdr = signTransaction.xdrEnvelope else { return outputXdr }
      outputXdr = xdr
    case .createdWithTangem:
      guard let xdr = signTransactionWithTangem.xdrEnvelope else { return outputXdr }
      outputXdr = xdr
    default:
      return outputXdr
    }
    return outputXdr
  }
  
  func updateTransactionAndSend(by hash: String) {
    let apiLoader = APIRequestLoader<TransactionRequest>(apiRequest: TransactionRequest())
    let transactionRequestParameters = TransactionRequestParameters(hash: hash)
    apiLoader.loadAPIRequest(requestData: transactionRequestParameters) { result in
      switch result {
      case .success(let transaction):
        guard let xdr = transaction.xdr,
              let transactionEnvelopeXDR = try? TransactionEnvelopeXDR(xdr: xdr),
              let transactionType = transaction.transactionType
        else {
          return
        }
        if let status = transaction.status, status == .pending {
          self.submitTransaction(transactionEnvelopeXDR, transactionType: transactionType)
        } else {
          DispatchQueue.main.async {
            self.view?.setProgressAnimation(isEnabled: false)
            self.view?.setTransactionAlreadySignedOrDeniedAlert()
          }
        }
      case .failure(let serverRequestError):
        self.view?.setProgressAnimation(isEnabled: false)
        switch serverRequestError {
        case .notFound:
          self.view?.showAlert(text: L10n.errorTransactionAlreadyConfirmedOrDeniedMessage)
        default:
          self.view?.setErrorAlert(for: serverRequestError)
        }
      }
    }
  }
  
  func getNumberOfNeededSignatures(thresholdsResponse: AccountThresholdsResponse, signers: [SignerViewData]) -> Int {
    let thresholds = [thresholdsResponse.lowThreshold, thresholdsResponse.medThreshold, thresholdsResponse.highThreshold]
    let filteredThresholds = thresholds.filter { $0 == thresholds.first }
    
    guard filteredThresholds.first != 0 else {
      isNeedToShowSignaturesNumber = false
      return 0
    }
    
    let areThresholdsEqual = filteredThresholds.count == thresholds.count
    
    let filteredSigners = signers.filter { $0.weight == signers.first?.weight }
    let areSignersWeightsEqual = filteredSigners.count == signers.count
    
    if areThresholdsEqual, areSignersWeightsEqual, let threshold = thresholds.first, let weight = signers.first?.weight {
      switch transaction.transactionType {
      case .transaction:
        isNeedToShowHelpfulMessage = true
      default:
        isNeedToShowHelpfulMessage = false
      }
      return threshold / weight
    }
    
    return signers.count
  }
  
  func setConfirmationAlert() {
    if isNeedToShowHelpfulMessage, isVaultAccountPending {
      if (numberOfNeededSignatures - numberOfAcceptedSignatures) > 1 {
        self.view?.showConfirmationAlert(with: L10n.textConfirmDialogDescriptionOtherSignaturesRequired)
      } else if (numberOfNeededSignatures - numberOfAcceptedSignatures) == 1 {
        self.view?.showConfirmationAlert(with: L10n.textConfirmDialogDescriptionNoOtherSignaturesRequired)
      } else {
        self.view?.showConfirmationAlert(with: L10n.textConfirmDialogDescription)
      }
    } else {
      self.view?.showConfirmationAlert(with: L10n.textConfirmDialogDescription)
    }
  }
  
  func getSignersViewData(signers: [AccountSignerResponse],
                          transactionEnvelopeXDR: TransactionEnvelopeXDR) -> [SignerViewData]
  {
    var signersViewData: [SignerViewData] = []
    let filteredSigners = signers.filter { $0.key != Constants.vaultMarkerKey }
    for (index, signer) in filteredSigners.enumerated() {
      let publicKey = signer.key
      let signed = TransactionHelper.isThereVerifiedSignature(for: publicKey, in: transactionEnvelopeXDR)
    
      let signatureStatus: SignatureStatus = signed ? .accepted : .pending
      let isLocalPublicKey = UserDefaultsHelper.activePublicKey == publicKey ? true : false
      let nickname = getNickname(for: publicKey, isLocalPublicKey: isLocalPublicKey)
      
      signersViewData.append(SignerViewData(status: signatureStatus,
                                            publicKey: publicKey,
                                            weight: signer.weight,
                                            federation: getFederation(by: publicKey, with: index),
                                            nickname: nickname,
                                            isLocalPublicKey: isLocalPublicKey))
    }
    
    return signersViewData
  }
  
  func getNickname(for publicKey: String, isLocalPublicKey: Bool) -> String {
    var nickname = ""
    if isLocalPublicKey {
      nickname = AccountsStorageHelper.getActiveAccountNickname()
    } else {
      if let account = storageAccounts.first(where: { $0.address == publicKey }) {
        nickname = account.nickname ?? ""
      } else {
        nickname = ""
      }
    }
    return nickname
  }
  
  func getFederation(by publicKey: String, with cellIndex: Int) -> String? {
    guard let account = storageAccounts.first(where: { $0.address == publicKey }) else {
      tryToLoadFederation(by: publicKey, for: cellIndex)
      return nil
    }
    
    return account.federation
  }
  
  func tryToLoadFederation(by publicKey: String, for index: Int) {
    federationService.getFederation(for: publicKey) { result in
      switch result {
      case .success(let account):
        if let federation = account.federation {
          var updatedSigner = self.signers[index]
          updatedSigner.federation = federation
          self.sections[TransactionDetailsSectionType.signers.index].rows[index] = .signer(updatedSigner)
          self.view?.reloadSignerListRow(index)
        }
      case .failure(let error):
        Logger.home.error("Couldn't get federation for \(publicKey) with error: \(error)")
      }
    }
  }
  
  func tryToGetDestinationId() -> String {
    var destinationId = ""
    do {
      let operation = try TransactionHelper.getOperation(from: xdr)
      switch type(of: operation) {
      case is PaymentOperation.Type:
        let paymentOperation = operation as! PaymentOperation
        destinationId = paymentOperation.destinationAccountId
      case is PathPaymentOperation.Type:
        let pathPaymentOperation = operation as! PathPaymentOperation
        destinationId = pathPaymentOperation.destinationAccountId
      case is CreateAccountOperation.Type:
        let createAccountOperation = operation as! CreateAccountOperation
        destinationId = createAccountOperation.destination.accountId
      case is AccountMergeOperation.Type:
        let accountMergeOperation = operation as! AccountMergeOperation
        destinationId = accountMergeOperation.destinationAccountId
      default:
        return destinationId
      }
    } catch {
      crashlyticsService?.recordCustomException(error)
      view?.setErrorAlert(for: error)
      return destinationId
    }
    return destinationId
  }
  
  func tryToGetSignedAccounts(transactionEnvelopeXDR: TransactionEnvelopeXDR) {
    self.storageAccounts = AccountsStorageHelper.getStoredAccounts()
    transactionService.getSignedAccounts { result in
      switch result {
      case .success(let accounts):
        let accountId = TransactionHelper.getAccountId(signedAccounts: accounts, transactionEnvelopeXDR: transactionEnvelopeXDR)
        self.sdk.accounts.getAccountDetails(accountId: accountId) { [weak self] result in
          guard let self = self else { return }
          self.isDownloading = false
          switch result {
          case .success(let accountDetails):
            DispatchQueue.main.async {
              self.view?.setProgressAnimation(isEnabled: false)
              self.accountSequenceNumber = Int(truncatingIfNeeded: accountDetails.sequenceNumber)
              let listOfTargetSigners = accountDetails.signers.filter {
                !($0.key.contains("VAULT")) && $0.weight != 0
              }
                
              self.signers = self.getSignersViewData(signers: listOfTargetSigners,
                                                     transactionEnvelopeXDR: transactionEnvelopeXDR)
              self.numberOfNeededSignatures = self.getNumberOfNeededSignatures(thresholdsResponse: accountDetails.thresholds,
                                                                               signers: self.signers)
              self.setData()
              if self.isAfterPushNotification && !self.checkIsActualSequenceNumber() {
                self.view?.hideButtonsWithError(withTextError: nil)
              } else {
                self.view?.setConfirmButtonWithError(isInvalid: self.transaction.sequenceOutdatedAt != nil, withTextError: nil)
              }
            }
          case .failure(let error):
            DispatchQueue.main.async {
              self.view?.setProgressAnimation(isEnabled: false)
              self.numberOfNeededSignatures = 0
              self.setData()
              self.view?.setConfirmButtonWithError(isInvalid: false, withTextError: error.localizedDescription)
              Logger.networking.error("Couldn't get account details with error: \(error)")
            }
          }
        }
      case .failure(let error):
        DispatchQueue.main.async {
          self.view?.setProgressAnimation(isEnabled: false)
          self.numberOfNeededSignatures = 0
          self.setData()
          self.view?.setConfirmButtonWithError(isInvalid: false, withTextError: error.localizedDescription)
          Logger.networking.error("Couldn't get account details with error: \(error)")
        }
      }
    }
  }
  
  func checkIsActualSequenceNumber() -> Bool {
    if txSequenceNumber != 0, txSequenceNumber <= accountSequenceNumber {
      return false
    } else {
      return true
    }
  }
  
  func checkSequenceNumberCount(completion: @escaping (Bool) -> Void) {
    transactionService.getSequenceNumberCount(for: txSourceAccountId, with: txSequenceNumber) { [weak self] result in
      guard let self = self else { return }
      
      switch result {
      case .success(let sequenceNumberCount):
        let sequenceNumberCountMinValue = self.transactionType == .standard ? 1 : 0
        if let sequenceNumberCount = sequenceNumberCount.count {
          if sequenceNumberCount > sequenceNumberCountMinValue {
            completion(false)
          } else {
            completion(true)
          }
        } else {
          completion(true)
        }
      case .failure(let error):
        completion(true)
        Logger.home.error("Couldn't get sequence number count for \(self.txSourceAccountId) with error: \(error)")
      }
    }
  }
  
  func reloadData() {
    updateSigners()
    setData()
  }
  
  func updateSigners() {
    var updatedSigners: [SignerViewData] = []
    storageAccounts = storage.retrieveAccounts() ?? []
    for signer in signers {
      if let index = storageAccounts.firstIndex(where: { $0.address == signer.publicKey }) {
        var signer = signer
        signer.nickname = storageAccounts[index].nickname
        updatedSigners.append(signer)
      } else {
        updatedSigners.append(signer)
      }
    }
    self.signers = updatedSigners
  }
  
  func savedToICloud(account: SignedAccount?) {
    CloudKitNicknameHelper.accountToSave = account
    if let accountToSave = CloudKitNicknameHelper.accountToSave {
      CloudKitNicknameHelper.saveToICloud(accountToSave)
    }
  }
}

// MARK: - Transitions

extension TransactionDetailsPresenterImpl {
  func transitionToTransactionListScreen() {
    let transactionDetailsViewController = view as! TransactionDetailsViewController
    transactionDetailsViewController.navigationController?.popToRootViewController(animated: true)
  }
  
  func transitionToTransactionStatus(with transactionResult: (TransactionResultCode, operationMessageError: String?), xdr: String?, transactionType: ServerTransactionType?, transactionHash: String?) {
    let transactionStatusViewController = TransactionStatusViewController.createFromStoryboard()
    
    transactionStatusViewController.presenter = TransactionStatusPresenterImpl(view: transactionStatusViewController,transactionResult: transactionResult,
      xdr: xdr, transactionType: transactionType, transactionHash: transactionHash)

    if let transactionDetailsViewController = view as? TransactionDetailsViewController {
      transactionDetailsViewController.navigationController?.pushViewController(transactionStatusViewController, animated: true)
    }
  }
  
  func transition(to operation: stellarsdk.Operation, by index: Int) {
    let operationViewController = OperationViewController.createFromStoryboard()
    
    operationViewController.presenter = OperationPresenterImpl(view: operationViewController, xdr: xdr)
    let memo = getMemo()
    var date = ""
    var transactionSourceAccountId = ""
    var maxFee: String?
    if let transactionDate = transaction.addedAt {
      date = TransactionHelper.getValidatedDate(from: transactionDate)
    }
    if let transactionXDR = try? TransactionEnvelopeXDR(xdr: xdr) {
      transactionSourceAccountId = transactionXDR.txSourceAccountId
      maxFee = getMaxFee(transactionXDR: transactionXDR)
    }
    operationViewController.presenter.setOperation(operation,
                                                   transactionSourceAccountId: transactionSourceAccountId,
                                                   maxFee: maxFee,
                                                   operationName: operations[index],
                                                   memo, date,
                                                   signers: self.signers,
                                                   numberOfNeededSignatures: self.numberOfNeededSignatures,
                                                   isNeedToShowHelpfulMessage: isNeedToShowHelpfulMessage,
                                                   isNeedToShowSignaturesNumber: isNeedToShowSignaturesNumber)
    
    let transactionDetailsViewController = view as! TransactionDetailsViewController
    transactionDetailsViewController.navigationController?.pushViewController(operationViewController, animated: true)
  }
  
  func getMemo() -> BeautifulMemo {
    var memo: BeautifulMemo = .none
    if let transactionXDR = try? TransactionEnvelopeXDR(xdr: xdr) {
      switch transactionXDR.txMemo {
      case .text(let text):
        if !text.isEmpty {
          memo = .text(text)
        }
      case .id(let id):
        memo = .id(String(id))
      case .returnHash(let returnHash):
        memo = .returnHash(returnHash.wrapped.hexString)
      case .hash(let hash):
        memo = .hash(hash.wrapped.hexString)
      default:
        break
      }
    }
    return memo
  }
}

private extension TransactionDetailsPresenterImpl {
  func addObservers() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidJWTTokenUpdate(_:)),
                                           name: .didJWTTokenUpdate,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(updateProgressAnimation(_:)),
                                           name: .didPinScreenClose,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidNicknameUpdate(_:)),
                                           name: .didNicknameSet,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidActivePublicKeyChange(_:)),
                                           name: .didActivePublicKeyChange,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidSignCardScan(_:)),
                                           name: .didSignCardScan,
                                           object: nil)
  }
}
