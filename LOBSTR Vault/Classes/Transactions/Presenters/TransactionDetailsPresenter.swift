import Foundation
import stellarsdk

protocol TransactionDetailsPresenter {
  func setTransactionData(_ transaction: Transaction)
  func transactionDetailsViewDidLoad()
}

protocol TransactionDetailsView: class {
  func displayOperationList()
}

class TransactionDetailsPresenterImpl: TransactionDetailsPresenter {
  
  fileprivate weak var view: TransactionDetailsView?
  fileprivate var transaction: Transaction?
  
  var operationNames: [String] = []
  var operationNumber = 0
  
  func initData(view: TransactionDetailsView) {
    self.view = view
  }
  
  // MARK: - TransactionDetailsPresenter
  
  func transactionDetailsViewDidLoad() {
    guard let transaction = transaction else { return }
    
    if let xdr = transaction.xdr {
      operationNames = TransactionHelper.getListOfOperationNames(from: xdr)
      operationNumber = operationNames.count
      view?.displayOperationList()
    }
  }
  
  func setTransactionData(_ transaction: Transaction) {
    self.transaction = transaction
  }
}
