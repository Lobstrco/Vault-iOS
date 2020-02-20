import Foundation
import stellarsdk

protocol OperationPresenter {
  var countOfOperationProperties: Int { get }
  func operationViewDidLoad()
  func configure(_ cell: OperationDetailsTableViewCell, forRow row: Int)
  func setOperation(_ operation: stellarsdk.Operation)
}

protocol OperationDetailsView: class {
  func setListOfOperationDetails()
}

class OperationPresenterImpl {
  
  fileprivate weak var view: OperationDetailsView?
  fileprivate weak var crashlyticsService: CrashlyticsService?
  fileprivate var operationProperties: [(name: String , value: String)] = []
  
  var operation: stellarsdk.Operation?
  
  // MARK: - Init
  
  init(view: OperationDetailsView, crashlyticsService: CrashlyticsService = CrashlyticsService()) {
    self.view = view
    self.crashlyticsService = crashlyticsService
  }
  
  // MARK: - Public
  
  func operationParse() {
    guard let parsedOperation = operation else { return }
    operationProperties = TransactionHelper.getNamesAndValuesOfProperties(from: parsedOperation)
  }
  
}

// MARK: - OperationDetailsPresenter

extension OperationPresenterImpl: OperationPresenter {
  
  var countOfOperationProperties: Int {
    return operationProperties.count
  }
  
  func operationViewDidLoad() {
    operationParse()
    view?.setListOfOperationDetails()
  }
  
  func setOperation(_ operation: stellarsdk.Operation) {
    self.operation = operation
  }
  
  func configure(_ cell: OperationDetailsTableViewCell, forRow row: Int) {
    cell.setData(title: operationProperties[row].name, value: operationProperties[row].value)
  }
}
