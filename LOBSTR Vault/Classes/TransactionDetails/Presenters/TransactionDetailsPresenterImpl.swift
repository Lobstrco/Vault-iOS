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
  
  private let transactionType: TransactionType
  private var operations: [String] = []
  private var signers: [SignerViewData] = []
  private var operationDetails: [(name: String, value: String, nickname: String, isPublicKey: Bool, isAssetCode: Bool)] = []
  private var destinationFederation: String = ""
  private var isDownloading: Bool = false
  private var assets: [stellarsdk.Asset] = []
  private var publicKeys: [String] = []
  
  var sections = [TransactionDetailsSection]()
  
  private let storage: AccountsStorage = AccountsStorageDiskImpl()
  private var storageAccounts: [SignedAccount] = []
  
  // MARK: - Init

  init(view: TransactionDetailsView,
       transaction: Transaction,
       type: TransactionType,
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
    addObservers()
  }
  
  @objc func onDidJWTTokenUpdate(_ notification: Notification) {
    transactionDetailsViewDidLoad()
  }
  
  @objc func updateProgressAnimation(_ notification: Notification) { 
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) { 
      self.view?.setProgressAnimation(isEnable: self.isDownloading)
    }
  }
}

// MARK: - TransactionDetailsPresenter

extension TransactionDetailsPresenterImpl: TransactionDetailsPresenter {
  func transactionDetailsViewDidLoad() {
    guard let transactionEnvelopeXDR = try? TransactionEnvelopeXDR(xdr: xdr),
          let viewController = view as? UIViewController,
          UtilityHelper.isTokenUpdated(view: viewController) else { return }
    
    view?.setProgressAnimation(isEnable: true)
    isDownloading = true
    let destinationId = tryToGetDestinationId()
    
    if !destinationId.isEmpty {
      federationService.getFederation(for: destinationId) { result in
        switch result {
        case .success(let account):
          if let federation = account.federation {
            self.destinationFederation = federation
            self.tryToGetSignedAccounts(transactionEnvelopeXDR: transactionEnvelopeXDR)
          }
        case .failure(let error):
          self.tryToGetSignedAccounts(transactionEnvelopeXDR: transactionEnvelopeXDR)
          Logger.home.error("Couldn't get federation for \(destinationId) with error: \(error)")
        }
      }
    }
    else {
      tryToGetSignedAccounts(transactionEnvelopeXDR: transactionEnvelopeXDR)
    }
  }
  
  func setData() {
    self.setOperationList()
    self.setOperationDetails()
    self.sections = self.buildSections()
    self.setTitle()
    self.registerTableViewCell()
    self.view?.reloadData()
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
          self.view?.showActionSheet(key, .publicKey)
        }
      } else {
        let shortPublicKey = key?.suffix(14) ?? ""
        let nickname = key?.replacingOccurrences(of: shortPublicKey, with: "")
        if let account = storageAccounts.first(where: { $0.nickname == nickname }) {
          if let key = self.publicKeys.first(where: { $0.prefix(4) == account.address?.prefix(4) && $0.suffix(4) == account.address?.suffix(4) }) {
            self.view?.showActionSheet(key, .publicKey)
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
      }
      else {
        self.view?.showActionSheet(nil, .nativeAssetCode)
      }
    }
  }
  
  func confirmButtonWasPressed() {
    guard UserDefaultsHelper.accountStatus == .createdByDefault else {
      confirmOperationWasConfirmed()
      return
    }
    
    if PromtForTransactionDecisionsHelper.isPromtTransactionDecisionsEnabled {
      view?.setConfirmationAlert()
    } else {
      confirmOperationWasConfirmed()
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
    
    view?.setProgressAnimation(isEnable: true)
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
}

// MARK: - Private

private extension TransactionDetailsPresenterImpl {
  func buildAdditionalInformationSection() -> [(name: String , value: String, nickname: String, isPublicKey: Bool)] {
    var additionalInformationSection: [(name: String , value: String, nickname: String, isPublicKey: Bool)] = []
        
    if let transactionXDR = try? TransactionEnvelopeXDR(xdr: xdr) {
      let memo = getMemo()
      
      if !memo.isEmpty {
        additionalInformationSection.append((name: "Memo", value: memo, nickname: "", isPublicKey: false))
      }
      
      additionalInformationSection.append((name: "Transaction Source", value: transactionXDR.txSourceAccountId.getTruncatedPublicKey(numberOfCharacters: TransactionHelper.numberOfCharacters), nickname: TransactionHelper.tryToGetNickname(publicKey: transactionXDR.txSourceAccountId), true))
      publicKeys.append(transactionXDR.txSourceAccountId)
    }
    
    if let transactionDate = transaction.addedAt {
      additionalInformationSection.append((name: "Created", value: TransactionHelper.getValidatedDate(from: transactionDate), nickname: "", isPublicKey: false))
    }
    
    return additionalInformationSection
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
        operationDetails = TransactionHelper.parseOperation(from: operation, transactionSourceAccountId: transactionXDR.txSourceAccountId, memo: nil, isListOperations: true, destinationFederation: self.destinationFederation)
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
    
    view?.setProgressAnimation(isEnable: true)
    
    transactionService.cancelTransaction(by: transactionHash) { result in
      switch result {
      case .success:
        DispatchQueue.main.async {
          NotificationCenter.default.post(name: .didRemoveTransaction,
                                          object: nil,
                                          userInfo: ["transactionIndex": transactionIndex])
          self.transitionToTransactionListScreen()
          self.view?.setProgressAnimation(isEnable: false)
        }
      case .failure(let error):
        DispatchQueue.main.async {
          self.view?.setErrorAlert(for: error)
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
      view?.setProgressAnimation(isEnable: false)
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
      view?.setProgressAnimation(isEnable: false)
      return
    }
    
    OperationQueue().addOperations(operations, waitUntilFinished: false)
    
    submitTransactionToHorizon.completionBlock = {
      DispatchQueue.main.async {
        self.view?.setProgressAnimation(isEnable: false)
        if let infoError = submitTransactionToHorizon.outputError as? ErrorDisplayable {
          self.view?.setErrorAlert(for: infoError)
          return
        }
        guard let horizonResult = submitTransactionToHorizon.horizonResult else { return }
        let xdr = self.getOutputXdr(signTransaction: signTransaction, signTransactionWithTangem: signTransactionWithTangem)
        NotificationCenter.default.post(name: .didChangeTransactionList, object: nil)
        self.transitionToTransactionStatus(with: horizonResult, xdr: xdr, transactionType: nil)
      }
    }
    
    submitTransactionToVaultServer.completionBlock = {
      DispatchQueue.main.async {
        self.view?.setProgressAnimation(isEnable: false)
        if let _ = submitTransactionToVaultServer.outputError {
          return
        }
        
        if transactionType == .authChallenge {
          NotificationCenter.default.post(name: .didChangeTransactionList, object: nil)
          let xdr = self.getOutputXdr(signTransaction: signTransaction, signTransactionWithTangem: signTransactionWithTangem)
          self.transitionToTransactionStatus(with: (TransactionResultCode.badAuth, operaiotnMessageError: nil), xdr: xdr, transactionType: .authChallenge)
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
        self.submitTransaction(transactionEnvelopeXDR, transactionType: transactionType)
      case .failure(let serverRequestError):
        self.view?.setErrorAlert(for: serverRequestError)
      }
    }
  }
  
  func getNumberOfNeededSignatures(thresholdsResponse: AccountThresholdsResponse, signers: [SignerViewData]) -> Int {
    let thresholds = [thresholdsResponse.lowThreshold, thresholdsResponse.medThreshold, thresholdsResponse.highThreshold]
    let filteredThresholds = thresholds.filter { $0 == thresholds.first }
    let areThresholdsEqual = filteredThresholds.count == thresholds.count
    
    let filteredSigners = signers.filter { $0.weight == signers.first?.weight }
    let areSignersWeightsEqual = filteredSigners.count == signers.count
    
    if areThresholdsEqual, areSignersWeightsEqual, let threshold = thresholds.first, let weight = signers.first?.weight {
      return threshold / weight
    }
    
    return signers.count
  }
  
  func getSignersViewData(signers: [AccountSignerResponse],
                          transactionEnvelopeXDR: TransactionEnvelopeXDR) -> [SignerViewData]
  {
    var signersViewData: [SignerViewData] = []
    let filteredSigners = signers.filter { $0.key != Constants.vaultMarkerKey }
    for (index, signer) in filteredSigners.enumerated() {
      guard let publicKey = signer.key else { break }
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
    guard let account = CoreDataStack.shared.fetch(Account.fetchBy(publicKey: publicKey)).first else {
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
    self.storageAccounts = storage.retrieveAccounts() ?? []
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
              self.view?.setProgressAnimation(isEnable: false)
              
              let listOfTargetSigners = accountDetails.signers.filter {
                !($0.key?.contains("VAULT") ?? false) && $0.weight != 0 }
                
              self.signers = self.getSignersViewData(signers: listOfTargetSigners,
                                                     transactionEnvelopeXDR: transactionEnvelopeXDR)
              self.numberOfNeededSignatures = self.getNumberOfNeededSignatures(thresholdsResponse: accountDetails.thresholds,
                                                                               signers: self.signers)
              self.setData()
              self.view?.setConfirmButtonWithError(isInvalid: self.transaction.sequenceOutdatedAt != nil, withTextError: nil)
            }
          case .failure(let error):
            DispatchQueue.main.async {
              self.view?.setProgressAnimation(isEnable: false)
              self.numberOfNeededSignatures = 0
              self.setData()
              self.view?.setConfirmButtonWithError(isInvalid: false, withTextError: error.localizedDescription)
              Logger.networking.error("Couldn't get account details with error: \(error)")
            }
          }
        }
      case .failure(let error):
        DispatchQueue.main.async {
          self.view?.setProgressAnimation(isEnable: false)
          self.numberOfNeededSignatures = 0
          self.setData()
          self.view?.setConfirmButtonWithError(isInvalid: false, withTextError: error.localizedDescription)
          Logger.networking.error("Couldn't get account details with error: \(error)")
        }
      }
    }
  }
}

// MARK: - Transitions

extension TransactionDetailsPresenterImpl {
  func transitionToTransactionListScreen() {
    let transactionDetailsViewController = view as! TransactionDetailsViewController
    transactionDetailsViewController.navigationController?.popToRootViewController(animated: true)
  }
  
  func transitionToTransactionStatus(with transactionResult: (TransactionResultCode, operaiotnMessageError: String?), xdr: String?, transactionType: ServerTransactionType?) {
    let transactionStatusViewController = TransactionStatusViewController.createFromStoryboard()
    
    transactionStatusViewController.presenter = TransactionStatusPresenterImpl(view:
      transactionStatusViewController,
      transactionResult: transactionResult,
      xdr: xdr, transactionType: transactionType)

    let transactionDetailsViewController = view as! TransactionDetailsViewController
    transactionDetailsViewController.navigationController?.pushViewController(transactionStatusViewController, animated: true)
  }
  
  func transition(to operation: stellarsdk.Operation, by index: Int) {
    let operationViewController = OperationViewController.createFromStoryboard()
    
    operationViewController.presenter = OperationPresenterImpl(view: operationViewController, xdr: xdr)
    let memo = getMemo()
    var date = ""
    var transactionSourceAccountId = ""
    if let transactionDate = transaction.addedAt {
      date = TransactionHelper.getValidatedDate(from: transactionDate)
    }
    if let transactionXDR = try? TransactionEnvelopeXDR(xdr: xdr) {
      transactionSourceAccountId = transactionXDR.txSourceAccountId
    }
    operationViewController.presenter.setOperation(operation, transactionSourceAccountId: transactionSourceAccountId, operationName: operations[index], memo, date, signers: self.signers, numberOfNeededSignatures: self.numberOfNeededSignatures, destinationFederation: destinationFederation)
    
    let transactionDetailsViewController = view as! TransactionDetailsViewController
    transactionDetailsViewController.navigationController?.pushViewController(operationViewController, animated: true)
  }
  
  func getMemo() -> String {
    var memo = ""
    if let transactionXDR = try? TransactionEnvelopeXDR(xdr: xdr) {
      switch transactionXDR.txMemo {
      case .text(let text):
        if !text.isEmpty {
          memo = text
        }
      case .id(let id):
        memo = String(id)
      case .returnHash(let returnHash):
        memo = returnHash.wrapped.asHexString()
      case .hash(let hash):
        memo = hash.wrapped.asHexString()
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
  }
}
