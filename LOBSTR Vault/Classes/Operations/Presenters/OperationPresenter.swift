import Foundation
import stellarsdk

protocol OperationPresenter {
  var countOfOperationProperties: Int { get }
  func operationViewDidLoad()
  func configure(_ cell: OperationDetailsTableViewCell, forRow row: Int)
}

protocol OperationDetailsView: class {
  func setListOfOperationDetails()
}

class OperationPresenterImpl: OperationPresenter{
  
  fileprivate weak var view: OperationDetailsView?
  fileprivate var operationProperties: [(name: String , value: String)] = []
  
  var countOfOperationProperties: Int {
    return operationProperties.count
  }
  
  var operation: stellarsdk.Operation?
  
  // MARK: - OperationDetailsPresenter
  
  func initData(view: OperationDetailsView) {
    self.view = view
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
  
  // MARK: - Public
  
  func operationParse() {
    guard let parsedOperation = operation else { return }
    operationProperties = TransactionHelper.getNamesAndValuesOfProperties(from: parsedOperation)
  }
  
}
