import Foundation
import stellarsdk

protocol OperationPresenter {
  var countOfOperationProperties: Int { get }
  var sections: [OperationDetailsSection] { get }
  var numberOfAcceptedSignatures: Int { get }
  var numberOfNeededSignatures: Int { get }
  func operationViewDidLoad()
  func setOperation(_ operation: stellarsdk.Operation, transactionSourceAccountId: String, operationName: String, _ memo: String, _ date: String, signers: [SignerViewData], numberOfNeededSignatures: Int, destinationFederation: String)
}

protocol OperationDetailsView: class {
  func setListOfOperationDetails()
  func setTitle(_ title: String)
}

class OperationPresenterImpl {
  fileprivate weak var view: OperationDetailsView?
  fileprivate weak var crashlyticsService: CrashlyticsService?
  fileprivate var operationProperties: [(name: String, value: String)] = []
  
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
  
  init(view: OperationDetailsView, crashlyticsService: CrashlyticsService = CrashlyticsService()) {
    self.view = view
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
}

private extension OperationPresenterImpl {
  func setOperationDetails() {
    guard let operation = operation else { return }
    operationProperties = TransactionHelper.parseOperation(from: operation, transactionSourceAccountId: transactionSourceAccountId, memo: memo, created: date, destinationFederation: destinationFederation)
  }

  func buildSections() -> [OperationDetailsSection] {
    var listOfSections = [OperationDetailsSection]()
    
    let operationDetailsSection = OperationDetailsSection(type: .operationDetails, rows: operationProperties.map { .operationDetail($0) })
    let signersSection = OperationDetailsSection(type: .signers, rows: signers.map { .signer($0) })
    
    listOfSections.append(contentsOf: [operationDetailsSection, signersSection])
    
    return listOfSections
  }
}
