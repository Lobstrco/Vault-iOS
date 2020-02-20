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
  
  var numberOfNeddedSignatures: Int = 0
  
  private let transactionType: TransactionType
  private var operations: [String] = []
  private var signers: [SignerViewData] = []
  private var operationDetails: [(name: String , value: String)] = []
  
  var sections = [TransactionDetailsSection]()
  
  // MARK: - Init

  init(view: TransactionDetailsView,
       transaction: Transaction,
       type: TransactionType,
       crashlyticsService: CrashlyticsService = CrashlyticsService(),
       transactionService: TransactionService = TransactionService(),
       federationService: FederationService = FederationService(),
       vaultStorage: VaultStorage = VaultStorage(),
       mnemonicManager: MnemonicManager = MnemonicManagerImpl(),
       sdk: StellarSDK = StellarSDK(withHorizonUrl: Environment.horizonBaseURL)) {
    self.view = view
    self.crashlyticsService = crashlyticsService
    self.transactionService = transactionService
    self.federationService = federationService
    self.mnemonicManager = mnemonicManager
    self.transaction = transaction
    self.transactionType = type
    self.sdk = sdk
    self.vaultStorage = vaultStorage
  }
}

// MARK: - TransactionDetailsPresenter

extension TransactionDetailsPresenterImpl: TransactionDetailsPresenter {
  
  func transactionDetailsViewDidLoad() {
    guard let transactionEnvelopeXDR = try? TransactionEnvelopeXDR(xdr: xdr) else {
        return
    }
    
    view?.setProgressAnimation(isEnable: true)
    
    sdk.accounts.getAccountDetails(accountId: transactionEnvelopeXDR.tx.sourceAccount.accountId) { [weak self] result in
      guard let self = self else { return }
      self.view?.setProgressAnimation(isEnable: false)
      switch result {
      case .success(let accountDetails):
        DispatchQueue.main.async {
          self.signers = self.getSignersViewData(signers: accountDetails.signers,
                                                 transactionEnvelopeXDR: transactionEnvelopeXDR)
          self.numberOfNeddedSignatures = self.getNumberOfNeddedSignatures(thresholdsResponse: accountDetails.thresholds,
                                                                           signers: self.signers)
          self.setOperationList()
          self.setOperationDetails()
          self.sections = self.buildSections()
          self.setTitle()
          self.disableBackButtonIfNecessary()
          self.registerTableViewCell()
          self.view?.reloadData()
          self.view?.setConfirmButtonWithError(isInvalid: self.transaction.sequenceOutdatedAt != nil)
        }
      case .failure(let error):
        Logger.networking.error("Couldn't get account details with error: \(error)")
      }
    }
  }
  
  func operationWasSelected(by index: Int) {
    do {
      let operation = try TransactionHelper.getOperation(from: xdr, by: index)
      transition(to: operation)
    } catch {
      crashlyticsService?.recordCustomException(error)
      view?.setErrorAlert(for: error)
    }
  }
  
  func confirmButtonWasPressed() {
    if UserDefaultsHelper.isPromtTransactionDecisionsEnabled {
      view?.setConfirmationAlert()
    } else {
      confirmOperationWasConfirmed()
    }
  }
  
  func denyButtonWasPressed() {
    if UserDefaultsHelper.isPromtTransactionDecisionsEnabled {
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
    switch transactionType {
    case .imported:
      guard let transactionEnvelopeXDR = try? TransactionEnvelopeXDR(xdr: xdr) else {
        return
      }
      submitTransaction(transactionEnvelopeXDR)
    case .standard:
      guard let hash = transaction.hash else {
        return
      }
      updateTransactionAndSend(by: hash)
    }
  }
}

// MARK: - Private

private extension TransactionDetailsPresenterImpl {
  
  func buildAdditionalInformationSection() -> [(name: String , value: String)] {
    var additionalInformationSection: [(name: String , value: String)] = []
    if let transactionDate = transaction.addedAt {
      additionalInformationSection.append((name: "Added at", value: TransactionHelper.getValidatedDate(from: transactionDate)))
    }
    
    if let transactionXDR = try? TransactionXDR(xdr: xdr) {
      switch transactionXDR.memo {
      case .text(let text):
        if !text.isEmpty {
          operationDetails.append((name: "Memo", value: text))
        }
      default:
        break
      }
      additionalInformationSection.append((name: "Source account", value: transactionXDR.sourceAccount.accountId))
    }
    
    
    
    return additionalInformationSection
  }
  
  func buildSections() -> [TransactionDetailsSection] {
    
    var listOfSections = [TransactionDetailsSection]()
    
    let operationsSection = TransactionDetailsSection(type: .operations, rows: operations.map { .operation($0) })
    let additionalInformationSection = TransactionDetailsSection(type: .additionalInformation, rows: buildAdditionalInformationSection().map { .additionalInformation($0)})
    let operationDetailsSection = TransactionDetailsSection(type: .operationDetails, rows: operationDetails.map { .operationDetail($0) })
    let signersSection = TransactionDetailsSection(type: .signers, rows: signers.map { .signer($0) })
    
    if operationsSection.rows.count > 1 {
      listOfSections.append(operationsSection)
    } else {
      listOfSections.append(operationDetailsSection)
    }
    
    listOfSections.append(contentsOf: [additionalInformationSection, signersSection])
    
    return listOfSections
  }
  
  func setOperationList() {
    do {
      guard let transactionXDR = try? TransactionXDR(xdr: xdr) else {
        throw VaultError.TransactionError.invalidTransaction
      }
      operations = try TransactionHelper.getListOfOperationNames(from: transactionXDR)
    } catch {
      crashlyticsService?.recordCustomException(error)
      view?.setErrorAlert(for: error)
      return
    }
  }
  
  func setOperationDetails() {
    guard operations.count == 1 else { return }
    do {
      let operation = try TransactionHelper.getOperation(from: xdr, by: 0)
      operationDetails = TransactionHelper.getNamesAndValuesOfProperties(from: operation)
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
  
  func disableBackButtonIfNecessary() {
    if transactionType == .imported {
      view?.disableBackButton()
    }
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
      case .success(_):
        NotificationCenter.default.post(name: .didRemoveTransaction,
                                        object: nil,
                                        userInfo: ["transactionIndex": transactionIndex])
        self.transitionToTransactionListScreen()
        self.view?.setProgressAnimation(isEnable: false)
      case .failure(let error):
        self.view?.setErrorAlert(for: error)
      }
    }
  }
  
  func submitTransaction(_ transactionEnvelopeXDR: TransactionEnvelopeXDR) {
    view?.setProgressAnimation(isEnable: true)
    
    let gettingMnemonic = GettingMnemonicOperation()
    let signTransaction = SignTransactionOperation(transactionEnvelopeXDR: transactionEnvelopeXDR)
    let submitTransactionToHorizon = SubmitTransactionToHorizonOperation()
    let submitTransactionToVaultServer = SubmitTransactionToVaultServerOperation()
    
    submitTransactionToVaultServer.addDependency(submitTransactionToHorizon)
    submitTransactionToHorizon.addDependency(signTransaction)
    signTransaction.addDependency(gettingMnemonic)
    
    let operationQueue = OperationQueue()
      
    operationQueue.addOperations([gettingMnemonic,
                                    signTransaction,
                                    submitTransactionToHorizon,
                                    submitTransactionToVaultServer],
                                   waitUntilFinished: false)
    
    submitTransactionToHorizon.completionBlock = {
      DispatchQueue.main.async {
        self.view?.setProgressAnimation(isEnable: false)
        
        if let infoError = submitTransactionToHorizon.outputError as? ErrorDisplayable {
          self.view?.setErrorAlert(for: infoError)
          return
        }
        
        guard let horizonResult = submitTransactionToHorizon.horizonResult else {
          return
        }
        
        guard let xdr = signTransaction.xdrEnvelope else {
          return
        }
        
        NotificationCenter.default.post(name: .didChangeTransactionList, object: nil)
        self.transitionToTransactionStatus(with: horizonResult, xdr: xdr)
      }
    }
    
    submitTransactionToVaultServer.completionBlock = {
      DispatchQueue.main.async {
        if let _ = submitTransactionToVaultServer.outputError {
          // check errors from vault server and send to crashlytics
        }
      }
    }
  }
  
  func updateTransactionAndSend(by hash: String) {
    let apiLoader = APIRequestLoader<TransactionRequest>(apiRequest: TransactionRequest())
    let transactionRequestParameters = TransactionRequestParameters(hash: hash)
    apiLoader.loadAPIRequest(requestData: transactionRequestParameters) { result in
      switch result {
      case .success(let transaction):
        guard let xdr = transaction.xdr,
          let transactionEnvelopeXDR = try? TransactionEnvelopeXDR(xdr: xdr) else {
            return
        }
        self.submitTransaction(transactionEnvelopeXDR)
      case .failure(let serverRequestError):
        self.view?.setErrorAlert(for: serverRequestError)
      }
    }
  }
  
  func getNumberOfNeddedSignatures(thresholdsResponse: AccountThresholdsResponse, signers: [SignerViewData]) -> Int {
    let thresholds = [thresholdsResponse.lowThreshold, thresholdsResponse.medThreshold, thresholdsResponse.highThreshold]
    let filteredThresholds = thresholds.filter { $0 == thresholds.first }
    let areThresholdsEqual = filteredThresholds.count == thresholds.count
    
    let filteredSigners = signers.filter { $0.weight == signers.first?.weight }
    let areSignersWeightsEqual = filteredSigners.count == signers.count
    
    if areThresholdsEqual, areSignersWeightsEqual, let threshold = thresholds.first, let weight = signers.first?.weight  {
      return threshold / weight
    }
    
    return signers.count
  }
  
  func getSignersViewData(signers: [AccountSignerResponse],
                          transactionEnvelopeXDR: TransactionEnvelopeXDR) -> [SignerViewData] {
    guard let hash = try? [UInt8](transactionEnvelopeXDR.tx.hash(network: .public)) else { return [] }
    var signersViewData: [SignerViewData] = []
    let filteredSigners = signers.filter { $0.key != Constants.vaultMarkerKey }
    
    for (index, signer) in filteredSigners.enumerated() {
      guard let key = signer.key, let signerKeyPair = try? KeyPair(accountId: key) else { continue }
      var signed = false
      for signature in transactionEnvelopeXDR.signatures {
        let sign = signature.signature
        let signatureIsValid = try! signerKeyPair.verify(signature: [UInt8](sign), message: hash)
        
        if signatureIsValid {
          signed = true
          break
        }
      }
    
      let signatureStatus: SignatureStatus = signed ? .accepted : .pending
      let isLocalPublicKey = vaultStorage.getPublicKeyFromKeychain() == key ? true : false
      signersViewData.append(SignerViewData(status: signatureStatus,
                                            publicKey: key,
                                            weight: signer.weight,
                                            federation: getFederation(by: key, with: index),
                                            isLocalPublicKey: isLocalPublicKey))
    }
    
    return signersViewData
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
}

// MARK: - Transitions

extension TransactionDetailsPresenterImpl {
 
  func transitionToTransactionListScreen() {
    let transactionDetailsViewController = view as! TransactionDetailsViewController
    transactionDetailsViewController.navigationController?.popToRootViewController(animated: true)
  }
  
  func transitionToTransactionStatus(with transactionResult: (TransactionResultCode, operaiotnMessageError: String?), xdr: String) {
    let transactionStatusViewController = TransactionStatusViewController.createFromStoryboard()
    
    transactionStatusViewController.presenter = TransactionStatusPresenterImpl(view: transactionStatusViewController,
                                                                               transactionResult: transactionResult,
                                                                               xdr: xdr)

    let transactionDetailsViewController = view as! TransactionDetailsViewController
    transactionDetailsViewController.navigationController?.pushViewController(transactionStatusViewController, animated: true)
  }
  
  func transition(to operation: stellarsdk.Operation) {
    let operationViewController = OperationViewController.createFromStoryboard()
    
    operationViewController.presenter = OperationPresenterImpl(view: operationViewController)
    operationViewController.presenter.setOperation(operation)
    
    let transactionDetailsViewController = view as! TransactionDetailsViewController
    transactionDetailsViewController.navigationController?.pushViewController(operationViewController, animated: true)
  }
}

