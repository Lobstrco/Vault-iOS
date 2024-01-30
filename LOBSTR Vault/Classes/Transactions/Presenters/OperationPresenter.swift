import Foundation
import stellarsdk

protocol OperationPresenter {
  var countOfOperationProperties: Int { get }
  var sections: [OperationDetailsSection] { get }
  var numberOfAcceptedSignatures: Int { get }
  var numberOfNeededSignatures: Int { get }
  var isNeedToShowHelpfulMessage: Bool { get }
  var isNeedToShowSignaturesNumber: Bool { get }
  
  var storageAccounts: [SignedAccount] { get }
  
  func operationViewDidLoad()
  func setOperation(_ operation: stellarsdk.Operation,
                    transactionSourceAccountId: String,
                    maxFee: String?,
                    operationName: String,
                    _ memo: BeautifulMemo,
                    _ date: String,
                    signers: [SignerViewData],
                    numberOfNeededSignatures: Int,
                    isNeedToShowHelpfulMessage: Bool,
                    isNeedToShowSignaturesNumber: Bool)
  func publicKeyWasSelected(key: String?)
  func assetCodeWasSelected(code: String?)
  func copyPublicKey(_ key: String)
  func explorerPublicKey(_ key: String)
  func explorerAsset(_ asset: stellarsdk.Asset)
  func explorerNativeAsset()
  func setNicknameActionWasPressed(with text: String?, for publicKey: String?, nicknameDialogType: NicknameDialogType?)
  func clearNicknameActionWasPressed(_ publicKey: String, nicknameDialogType: NicknameDialogType?)
  func signerWasSelected(_ viewData: SignerViewData?)
  func proceedICloudSyncActionWasPressed()
}

protocol OperationDetailsView: AnyObject {
  func setListOfOperationDetails()
  func setTitle(_ title: String)
  func showActionSheet(_ value: Any?, _ type: ActionSheetType)
  func copy(_ text: String)
  func showICloudSyncAdviceAlert()
  func showNoInternetConnectionAlert()
  func showICloudSyncScreen()
  func setProgressAnimation(isEnabled: Bool)
}

class OperationPresenterImpl {
  fileprivate weak var view: OperationDetailsView?
  fileprivate weak var crashlyticsService: CrashlyticsService?
  fileprivate var operationProperties: [(name: String, value: String, nickname: String, isPublicKey: Bool, isAssetCode: Bool)] = []
  fileprivate var xdr: String
  private let federationService: FederationService
  
  var operation: stellarsdk.Operation?
  var transactionSourceAccountId: String = ""
  var operationName: String = ""
  var memo: BeautifulMemo?
  var date: String?
  var destinationFederation: String = ""
  var maxFee: String?
  
  var numberOfAcceptedSignatures: Int {
    return signers
      .filter { $0.status == .accepted }
      .count
  }
  
  var numberOfNeededSignatures: Int = 0
  var isNeedToShowHelpfulMessage: Bool = false
  var isNeedToShowSignaturesNumber: Bool = true
  var signers: [SignerViewData] = []
  var sections = [OperationDetailsSection]()
  
  private let storage: AccountsStorage = AccountsStorageDiskImpl()
  var storageAccounts: [SignedAccount] = []
  
  // MARK: - Init
  
  init(view: OperationDetailsView, xdr: String,
       crashlyticsService: CrashlyticsService = CrashlyticsService(),
       federationService: FederationService = FederationService()) {
    self.view = view
    self.xdr = xdr
    self.crashlyticsService = crashlyticsService
    self.federationService = federationService
  }
}

// MARK: - OperationDetailsPresenter

extension OperationPresenterImpl: OperationPresenter {
  var countOfOperationProperties: Int {
    return operationProperties.count
  }
  
  func operationViewDidLoad() {
    storageAccounts = AccountsStorageHelper.getStoredAccounts()
    view?.setTitle(operationName)
    getDestinationFederation()
  }
  
  func setOperation(_ operation: stellarsdk.Operation,
                    transactionSourceAccountId: String,
                    maxFee: String?,
                    operationName: String,
                    _ memo: BeautifulMemo,
                    _ date: String,
                    signers: [SignerViewData],
                    numberOfNeededSignatures: Int,
                    isNeedToShowHelpfulMessage: Bool,
                    isNeedToShowSignaturesNumber: Bool) {
    self.operation = operation
    self.transactionSourceAccountId = transactionSourceAccountId
    self.maxFee = maxFee
    self.operationName = operationName
    self.memo = memo
    self.date = date
    self.signers = signers
    self.numberOfNeededSignatures = numberOfNeededSignatures
    self.isNeedToShowHelpfulMessage = isNeedToShowHelpfulMessage
    self.isNeedToShowSignaturesNumber = isNeedToShowSignaturesNumber
  }
  
  func publicKeyWasSelected(key: String?) {
    if let operation = operation {
      var publicKeys = TransactionHelper.getPublicKeys(from: operation)
      publicKeys.append(transactionSourceAccountId)
      if let key = key, key.isShortStellarPublicAddress || key.isShortMuxedAddress {
        if let key = publicKeys.first(where: { $0.prefix(4) == key.prefix(4) && $0.suffix(4) == key.suffix(4) }) {
          TransactionHelper.isVaultSigner(publicKey: key) { result in
            self.view?.showActionSheet(key, .publicKey(isNicknameSet: false, isVaultSigner: result))
          }
        } else if transactionSourceAccountId.prefix(4) == key.prefix(4) && transactionSourceAccountId.suffix(4) == key.suffix(4) {
          TransactionHelper.isVaultSigner(publicKey: transactionSourceAccountId) { result in
            self.view?.showActionSheet(self.transactionSourceAccountId, .publicKey(isNicknameSet: false, isVaultSigner: result))
          }
        }
      } else {
        let secondPartOfKey = key?.suffix(14) ?? ""
        let shortPublicKey = TransactionHelper.getShortPublicKey(String(secondPartOfKey))
        if let nickname = key?.replacingOccurrences(of: secondPartOfKey, with: ""),
           let account = storageAccounts.first(where: { $0.nickname == nickname && $0.address?.prefix(4) == shortPublicKey.prefix(4) && $0.address?.suffix(4) == shortPublicKey.suffix(4) }) {
          if let key = publicKeys.first(where: { $0.prefix(4) == account.address?.prefix(4) && $0.suffix(4) == account.address?.suffix(4) }) {
            TransactionHelper.isVaultSigner(publicKey: key) { result in
              self.view?.showActionSheet(key, .publicKey(isNicknameSet: !nickname.isEmpty, isVaultSigner: result))
            }
          }
        }
      }
    }
  }
  
  func assetCodeWasSelected(code: String?) {
    if let operation = operation {
      let assets = TransactionHelper.getAssets(from: operation)
      if !assets.isEmpty {
        if let asset = assets.first(where: { $0.code == code }) {
          view?.showActionSheet(asset, .assetCode)
        }
        else {
          view?.showActionSheet(nil, .nativeAssetCode)
        }
      }
    }
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
    updateSigners()
    operationViewDidLoad()
    
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

private extension OperationPresenterImpl {
  func getDestinationFederation() {
    let destinationId = tryToGetDestinationId()
    
    if !destinationId.isEmpty {
      view?.setProgressAnimation(isEnabled: true)
      federationService.getFederation(for: destinationId) { result in
        self.view?.setProgressAnimation(isEnabled: false)
        switch result {
        case .success(let account):
          DispatchQueue.main.async {
            if let federation = account.federation {
              self.destinationFederation = federation
              self.setOperationDetails()
            } else {
              self.setOperationDetails()
            }
          }
        case .failure(let error):
          Logger.home.error("Couldn't get federation for \(destinationId) with error: \(error)")
          DispatchQueue.main.async {
            self.setOperationDetails()
          }
        }
      }
    } else {
      setOperationDetails()
    }
  }
  
  func setOperationDetails() {
    setOperationProperties()
    sections = buildSections()
    view?.setListOfOperationDetails()
  }
  
  func setOperationProperties() {
    guard let operation = operation else { return }
    operationProperties = TransactionHelper.parseOperation(from: operation, transactionSourceAccountId: transactionSourceAccountId, destinationFederation: destinationFederation)
  }
  
  func tryToGetDestinationId() -> String {
    var destinationId = ""
    guard let operation = operation else { return destinationId }
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
    return destinationId
  }

  func buildAdditionalInformationSection() -> [(name: String , value: String, nickname: String, isPublicKey: Bool)] {
    var additionalInformationSection: [(name: String , value: String, nickname: String, isPublicKey: Bool)] = []
    if let memo = self.memo, !memo.value.isEmpty {
      additionalInformationSection.append((name: memo.title, value: memo.value, nickname: "", isPublicKey: false))
    }
    additionalInformationSection.append((name: "Transaction Source", value: transactionSourceAccountId.getTruncatedPublicKey(numberOfCharacters: TransactionHelper.numberOfCharacters), nickname: TransactionHelper.tryToGetNickname(publicKey: transactionSourceAccountId), isPublicKey: true))
    
    if let maxFee = maxFee {
      additionalInformationSection.append((name: "Max Network Fee", value: maxFee + " XLM", nickname: "", isPublicKey: false))
    }
    
    if let transactionDate = self.date, !transactionDate.isEmpty {
      additionalInformationSection.append((name: "Created", value: transactionDate, nickname: "", isPublicKey: false))
    }
    return additionalInformationSection
  }
  
  func buildSections() -> [OperationDetailsSection] {
    var listOfSections = [OperationDetailsSection]()
    
    let operationDetailsSection = OperationDetailsSection(type: .operationDetails, rows: operationProperties.map { .operationDetail($0) })
    let signersSection = OperationDetailsSection(type: .signers, rows: signers.map { .signer($0) })
            
    let additionalInformationSection = OperationDetailsSection(type: .additionalInformation, rows: buildAdditionalInformationSection().map { .additionalInformation($0) })
    
    listOfSections.append(contentsOf: [additionalInformationSection, operationDetailsSection, signersSection])
    
    return listOfSections
  }
  
  func updateSigners() {
    var updatedSigners: [SignerViewData] = []
    storageAccounts = AccountsStorageHelper.getStoredAccounts()
    for signer in signers {
      if let index = storageAccounts.firstIndex(where: { $0.address == signer.publicKey }) {
        var signer = signer
        signer.nickname = storageAccounts[index].nickname
        updatedSigners.append(signer)
      } else {
        updatedSigners.append(signer)
      }
    }
    signers = updatedSigners
  }
  
  func savedToICloud(account: SignedAccount?) {
    CloudKitNicknameHelper.accountToSave = account
    if let accountToSave = CloudKitNicknameHelper.accountToSave {
      CloudKitNicknameHelper.saveToICloud(accountToSave)
    }
  }
}
