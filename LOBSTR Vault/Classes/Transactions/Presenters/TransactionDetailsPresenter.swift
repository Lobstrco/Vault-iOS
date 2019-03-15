import Foundation
import stellarsdk

protocol TransactionDetailsPresenter {
  var numberOfOperation: Int { get }
  var numberOfOperationDetails: Int { get }
  var transactionListIndex: Int? { get set }
  func transactionDetailsViewDidLoad()
  func operationWasSelected(by index: Int)
  func confirmButtonWasPressed()
  func denyButtonWasPressed()
  func denyOperationWasConfirmed()
  func configure(_ cell: OperationTableViewCell, forRow row: Int)
  func configure(_ cell: OperationDetailsTableViewCell, forRow row: Int)
}

protocol TransactionDetailsView: class {
  func setTableViewData()
  func setConfirmationAlert()
  func setErrorAlert(for error: Error)
  func setProgressAnimation(isEnable: Bool)
  func registerTableViewCell(with cellName: String)
  func setConfirmButtonWithError(isInvalid: Bool)
  func setTitle(_ title: String)
  func disableBackButton()
  func openTransactionListScreen()
}

enum TransactionType {
  case imported
  case standard
}

class TransactionDetailsPresenterImpl {
  
  fileprivate weak var view: TransactionDetailsView?
  fileprivate weak var crashlyticsService: CrashlyticsService?
  fileprivate var transactionService: TransactionService
  fileprivate var mnemonicManager: MnemonicManager
  fileprivate var indexInTransactionList: Int?
  
  fileprivate let transaction: Transaction
  fileprivate var xdr: String
  fileprivate let transactionType: TransactionType
  
  fileprivate var operations: [String] = []
  fileprivate var operationDetails: [(name: String , value: String)] = []
  
  var transactionListIndex: Int? {
    get { return indexInTransactionList }
    set { indexInTransactionList = newValue }
  }
  
  var numberOfOperation: Int {
    return operations.count
  }
  
  var numberOfOperationDetails: Int {
    return operationDetails.count
  }
  
  // MARK: - Init

  init(view: TransactionDetailsView,
       transaction: Transaction,
       type: TransactionType,
       crashlyticsService: CrashlyticsService = CrashlyticsService(),
       transactionService: TransactionService = TransactionService(),
       mnemonicManager: MnemonicManager = MnemonicManagerImpl()) {
    self.view = view
    self.crashlyticsService = crashlyticsService
    self.transactionService = transactionService
    self.mnemonicManager = mnemonicManager
    self.transaction = transaction
    self.transactionType = type
    
    guard let transactionXDR = transaction.xdr else {
      fatalError()
    }
    
    self.xdr = transactionXDR
  }
  
  // MARK: - Private
  
  private func setOperationList() {
    do {
      operations = try TransactionHelper.getListOfOperationNames(from: xdr)
    } catch {
      crashlyticsService?.recordCustomException(error)
      view?.setErrorAlert(for: error)
      return
    }
  }
  
  private func setOperationDetails() {
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
  
  private func setTitle() {
    var title = L10n.navTitleTransactionDetails
    
    if operations.count == 1, let operationName = operations.first {
      title = operationName
    }
    
    view?.setTitle(title)
  }
  
  private func disableBackButtonIfNecessary() {
    if transactionType == .imported {
      view?.disableBackButton()
    }
  }
  
  private func registerTableViewCell() {
    let cellName = numberOfOperation == 1 ? "OperationDetailsTableViewCell" : "OperationTableViewCell"
    view?.registerTableViewCell(with: cellName)
  }
  
  private func openTransactionListScreen() {
    view?.openTransactionListScreen()
  }
  
  private func cancelTransaction() {
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
  
  private func submitTransaction(_ transactionEnvelopeXDR: TransactionEnvelopeXDR) {
    view?.setProgressAnimation(isEnable: true)
    
    let gettingMnemonic = GettingMnemonicOperation()
    let signTransaction = SignTransactionOperation(transactionEnvelopeXDR: transactionEnvelopeXDR)
    let submitTransactionToHorizon = SubmitTransactionToHorizonOperation()
    let submitTransactionToVaultServer = SubmitTransactionToVaultServerOperation(transactionHash: transaction.hash)
    
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
        
        guard let resultCode = submitTransactionToHorizon.horizonResultCode else {
          return
        }
        
        guard let xdr = signTransaction.xdrEnvelope else {
          return
        }
        
        NotificationCenter.default.post(name: .didChangeTransactionList, object: nil)
        self.transitionToTransactionStatus(with: resultCode, xdr: xdr)
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
}

// MARK: - TransactionDetailsPresenter

extension TransactionDetailsPresenterImpl: TransactionDetailsPresenter {
  
  func transactionDetailsViewDidLoad() {
    setOperationList()
    setOperationDetails()
    setTitle()
    disableBackButtonIfNecessary()
    
    registerTableViewCell()
    view?.setTableViewData()
    view?.setConfirmButtonWithError(isInvalid: transaction.sequenceOutdatedAt != nil)
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
  
  func denyButtonWasPressed() {
    view?.setConfirmationAlert()
  }
  
  func configure(_ cell: OperationTableViewCell, forRow row: Int) {
    cell.setOperationTitle(operations[row])
  }
  
  func configure(_ cell: OperationDetailsTableViewCell, forRow row: Int) {
      cell.setData(title: operationDetails[row].name, value: operationDetails[row].value)
  }
  
  func confirmButtonWasPressed() {
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
  
  private func updateTransactionAndSend(by hash: String) {
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
  
  func denyOperationWasConfirmed() {
    switch transactionType {
    case .imported:
      openTransactionListScreen()
    case .standard:
      cancelTransaction()
    }
  }
}

// MARK: - Transitions

extension TransactionDetailsPresenterImpl {
 
  func transitionToTransactionListScreen() {
    let transactionDetailsViewController = view as! TransactionDetailsViewController
    transactionDetailsViewController.navigationController?.popToRootViewController(animated: true)
  }
  
  func transitionToTransactionStatus(with resultCode: TransactionResultCode, xdr: String) {
    let transactionStatusViewController = TransactionStatusViewController.createFromStoryboard()
    
    transactionStatusViewController.presenter = TransactionStatusPresenterImpl(view: transactionStatusViewController,
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

