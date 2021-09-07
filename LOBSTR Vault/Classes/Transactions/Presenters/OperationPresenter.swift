import Foundation
import stellarsdk

protocol OperationPresenter {
  var countOfOperationProperties: Int { get }
  var sections: [OperationDetailsSection] { get }
  var numberOfAcceptedSignatures: Int { get }
  var numberOfNeededSignatures: Int { get }
  func operationViewDidLoad()
  func setOperation(_ operation: stellarsdk.Operation, transactionSourceAccountId: String, operationName: String, _ memo: String, _ date: String, signers: [SignerViewData], numberOfNeededSignatures: Int, destinationFederation: String)
  func publicKeyWasSelected(key: String?)
  func assetCodeWasSelected(code: String?)
  func copyPublicKey(_ key: String)
  func explorerPublicKey(_ key: String)
  func explorerAsset(_ asset: stellarsdk.Asset)
  func explorerNativeAsset()
}

protocol OperationDetailsView: class {
  func setListOfOperationDetails()
  func setTitle(_ title: String)
  func showActionSheet(_ value: Any?, _ type: ActionSheetType)
  func copy(_ text: String)
}

class OperationPresenterImpl {
  fileprivate weak var view: OperationDetailsView?
  fileprivate weak var crashlyticsService: CrashlyticsService?
  fileprivate var operationProperties: [(name: String, value: String, isAssetCode: Bool)] = []
  fileprivate var xdr: String
  
  var operation: stellarsdk.Operation?
  var transactionSourceAccountId: String = ""
  var operationName: String = ""
  var memo: String?
  var date: String?
  var destinationFederation: String = ""
  
  var numberOfAcceptedSignatures: Int {
    return signers
      .filter { $0.status == .accepted }
      .count
  }
  
  var numberOfNeededSignatures: Int = 0
  var signers: [SignerViewData] = []
  var sections = [OperationDetailsSection]()
  
  // MARK: - Init
  
  init(view: OperationDetailsView, xdr: String, crashlyticsService: CrashlyticsService = CrashlyticsService()) {
    self.view = view
    self.xdr = xdr
    self.crashlyticsService = crashlyticsService
  }
}

// MARK: - OperationDetailsPresenter

extension OperationPresenterImpl: OperationPresenter {
  var countOfOperationProperties: Int {
    return operationProperties.count
  }
  
  func operationViewDidLoad() {
    view?.setTitle(operationName)
    self.setOperationDetails()
    self.sections = self.buildSections()
    view?.setListOfOperationDetails()
  }
  
  func setOperation(_ operation: stellarsdk.Operation, transactionSourceAccountId: String, operationName: String, _ memo: String, _ date: String, signers: [SignerViewData], numberOfNeededSignatures: Int, destinationFederation: String) {
    self.operation = operation
    self.transactionSourceAccountId = transactionSourceAccountId
    self.operationName = operationName
    self.destinationFederation = destinationFederation
    self.memo = memo
    self.date = date
    self.signers = signers
    self.numberOfNeededSignatures = numberOfNeededSignatures
  }
  
  func publicKeyWasSelected(key: String?) {
    if let operation = operation {
      let publicKeys = TransactionHelper.getPublicKeys(from: operation)
      if let key = publicKeys.first(where: { $0.prefix(4) == key?.prefix(4) && $0.suffix(4) == key?.suffix(4) }) {
        self.view?.showActionSheet(key, .publicKey)
      } else if transactionSourceAccountId.prefix(4) == key?.prefix(4) && transactionSourceAccountId.suffix(4) == key?.suffix(4) {
        self.view?.showActionSheet(transactionSourceAccountId, .publicKey)
      }
    }
  }
  
  func assetCodeWasSelected(code: String?) {
    do {
      let operation = try TransactionHelper.getOperation(from: xdr)
      let assets = TransactionHelper.getAssets(from: operation)
      if !assets.isEmpty {
        if let asset = assets.first(where: { $0.code == code }) {
          self.view?.showActionSheet(asset, .assetCode)
        }
        else {
          self.view?.showActionSheet(nil, .nativeAssetCode)
        }
      }
    } catch {
      return
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
}

private extension OperationPresenterImpl {
  func setOperationDetails() {
    guard let operation = operation else { return }
    operationProperties = TransactionHelper.parseOperation(from: operation, transactionSourceAccountId: transactionSourceAccountId, memo: memo, destinationFederation: destinationFederation)
  }
  
  
  func buildAdditionalInformationSection() -> [(name: String, value: String)] {
    var additionalInformationSection: [(name: String, value: String)] = []
    if let memo = self.memo, !memo.isEmpty {
      additionalInformationSection.append((name: "Memo", value: memo))
    }
    additionalInformationSection.append((name: "Transaction Source", value: transactionSourceAccountId.getTruncatedPublicKey(numberOfCharacters: TransactionHelper.numberOfCharacters)))
    if let transactionDate = self.date, !transactionDate.isEmpty {
      additionalInformationSection.append((name: "Created", value: transactionDate))
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
}
