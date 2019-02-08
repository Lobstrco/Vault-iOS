import Foundation
import stellarsdk

protocol TransactionDetailsPresenter {
  var numberOfOperation: Int { get }
  func setTransactionData(_ transaction: Transaction, withIndex: Int)
  func transactionDetailsViewDidLoad()
  func operationWasSelected(by index: Int)
  func confirmButtonWasPressed()
  func denyButtonWasPressed()
  func denyOperationWasConfirmed()
  func configure(_ cell: OperationTableViewCell, forRow row: Int)
}

protocol TransactionDetailsView: class {
  func setOperationList()
  func setConfirmationAlert()
  func setErrorAlert(for error: Error)
  func setProgressAnimation(isEnable: Bool)
}

class TransactionDetailsPresenterImpl {
  
  fileprivate weak var view: TransactionDetailsView?
  fileprivate weak var crashlyticsService: CrashlyticsService?
  fileprivate var transactionService: TransactionService
  fileprivate var mnemonicManager: MnemonicManager
  fileprivate var transaction: Transaction?
  fileprivate var indexForTransactionList: Int?
  
  fileprivate var operationNames: [String] = []
  
  var numberOfOperation: Int {
    return operationNames.count
  }
  
  // MARK: - Init

  init(view: TransactionDetailsView,
       crashlyticsService: CrashlyticsService = CrashlyticsService(),
       transactionService: TransactionService = TransactionService(),
       mnemonicManager: MnemonicManager = MnemonicManagerImpl()) {
    self.view = view
    self.crashlyticsService = crashlyticsService
    self.transactionService = transactionService
    self.mnemonicManager = mnemonicManager
  }
  
  // MARK: - Public
  
  func setOperationList() {
    guard let transaction = transaction else { return }
    guard let xdr = transaction.xdr else { return }
    
    do {
      operationNames = try TransactionHelper.getListOfOperationNames(from: xdr)
    } catch {
      crashlyticsService?.recordCustomException(error)
      view?.setErrorAlert(for: error)
      return
    }
    
    view?.setOperationList()
  }
  
  // MARK: - Private
  
  private func submitTransaction(with transactionEnvelope: String) {
    StellarSDK(withHorizonUrl: Constants.horizonURL).transactions.postTransaction(transactionEnvelope: transactionEnvelope) { (response) -> (Void) in
      switch response {
      case .success(_):
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
          self.submitTransactionToVaultServer(transactionEnvelope)
        }
      case .failure(let error):
        switch error {
        case .badRequest(let message, _):
          let resultCode = try! TransactionHelper.getTransactionResultCode(from: message)
          switch resultCode {
          case .badAuth:
            self.submitTransactionToVaultServer(transactionEnvelope, isNeedAdditionalSignature: true)
          default:
            DispatchQueue.main.async {
              self.transitionToTransactionStatus(.failure, resultCode: resultCode)
              self.view?.setProgressAnimation(isEnable: false)
            }
          }
        default:
          self.view?.setProgressAnimation(isEnable: false)
          self.view?.setErrorAlert(for: error)
        }
      }
    }
  }
  
  private func submitTransactionToVaultServer(_ transactionEnvelope: String, isNeedAdditionalSignature: Bool = false) {
    transactionService.submitSignedTransaction(xdr: transactionEnvelope, isNeedAdditionalSignature: isNeedAdditionalSignature) { result in
      switch result {
      case .success(_):
        DispatchQueue.main.async {
          let resultCode: TransactionResultCode = isNeedAdditionalSignature ? .badAuth : .success
          let xdr: String? = isNeedAdditionalSignature ? transactionEnvelope : nil
          
          self.transitionToTransactionStatus(.success, resultCode: resultCode, xdr: xdr)
          self.view?.setProgressAnimation(isEnable: false)
        }
        NotificationCenter.default.post(name: .didChangeTransactionList, object: nil)
      case .failure(let error):
        self.view?.setErrorAlert(for: error)
        self.view?.setProgressAnimation(isEnable: false)
      }
    }
  }
}

// MARK: - TransactionDetailsPresenter

extension TransactionDetailsPresenterImpl: TransactionDetailsPresenter {
  
  func transactionDetailsViewDidLoad() {
    setOperationList()
  }
  
  func setTransactionData(_ transaction: Transaction, withIndex indexForTransactionList: Int) {
    self.transaction = transaction
    self.indexForTransactionList = indexForTransactionList
  }
  
  func operationWasSelected(by index: Int) {
    guard let xdr = transaction?.xdr else { return }
    
    do {
      let operation = try TransactionHelper.getOperation(from: xdr, by: index)
      transition(to: operation)
    } catch {
      crashlyticsService?.recordCustomException(error)
      view?.setErrorAlert(for: error)
    }
  }
  
  func denyButtonWasPressed() {
    view?.setConfirmationAlert()
  }
  
  func configure(_ cell: OperationTableViewCell, forRow row: Int) {
    cell.setOperationTitle(operationNames[row])
  }
  
  func confirmButtonWasPressed() {
    view?.setProgressAnimation(isEnable: true)
    guard let xdr = self.transaction?.xdr else {
      return
    }

    guard let transactionEnvelopeXDR = try? TransactionEnvelopeXDR(xdr: xdr) else {
      return
    }
    
    TransactionHelper.signTransaction(transactionEnvelopeXDR: transactionEnvelopeXDR,
                                      mnemonicManager: mnemonicManager) { result in
      switch result {
      case .success(let transactionEnvelope):
        self.submitTransaction(with: transactionEnvelope)
      case .failure(let error):
        self.view?.setProgressAnimation(isEnable: false)
        self.view?.setErrorAlert(for: error)
      }
    }
  }
  
  func denyOperationWasConfirmed() {
    guard let transactionHash = transaction?.hash else {
      let error = VaultError.TransactionError.invalidTransaction
      view?.setErrorAlert(for: error)
      return
    }
    
    guard let transactionIndex = indexForTransactionList else {
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
}

// MARK: - Transitions

extension TransactionDetailsPresenterImpl {
 
  func transitionToTransactionListScreen() {
    let transactionDetailsViewController = view as! TransactionDetailsViewController
    transactionDetailsViewController.navigationController?.popToRootViewController(animated: true)
  }
  
  func transitionToTransactionStatus(_ status: TransactionStatus, resultCode: TransactionResultCode, xdr: String? = nil) {
    let transactionStatusViewController = TransactionStatusViewController.createFromStoryboard()
    
    transactionStatusViewController.presenter = TransactionStatusPresenterImpl(view: transactionStatusViewController,
                                                                               with: status,
                                                                               resultCode: resultCode,
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

