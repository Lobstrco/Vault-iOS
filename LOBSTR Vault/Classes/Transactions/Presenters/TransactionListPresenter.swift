import Foundation
import stellarsdk

enum TaskStatus {
  case ready
  case loading
  case failure
}

protocol TransactionListView: class {
  func setErrorAlert(for error: Error)
  func setImportXDRPopover(_ popover: CustomPopoverViewController)
  func setHUDSuccessViewAfterRemoveOperation()
  func setTransactionList(viewModels: [TransactionListTableViewCell.ViewModel], isResetData: Bool)
  func updateFederataionAddress(_ address: String, for indexItem: Int)
  func setProgressAnimation(isEnabled: Bool, didBecomeActive: Bool)
  func setProgressAnimationAfterDelete(isEnabled: Bool)
  func setProgressAnimationAfterError()
  func setClearButton(isHidden: Bool)
}

protocol TransactionListPresenter {
  func transactionWasSelected(with index: Int)
  func transactionListViewDidLoad()
  func transactionListViewDidAppear()
  func importXDRButtonWasPressed()
  func clearAllTransactions()
  func clearInvalidTransactions()
  func pullToRefreshWasActivated()
  func tableViewReachedBottom()
}

protocol TransactionListCellView {
  var viewModel: TransactionListTableViewCell.ViewModel? { get set }
}

class TransactionListPresenterImpl {
  private weak var view: TransactionListView?
  private var transactionList: [Transaction] = []
  private let crashlyticsService: CrashlyticsService
  private let transactionService: TransactionService
  private let federationService: FederationService
  private var transactionListStatus: TaskStatus = .ready
  
  private var currentPageNumber: Int? = 1
  
  private let storage: SignersStorage = SignersStorageDiskImpl()
  private var storageSigners: [SignedAccount] = []
  
  init(view: TransactionListView,
       federationService: FederationService = FederationService(),
       crashlyticsService: CrashlyticsService = CrashlyticsService(),
       transactionService: TransactionService = TransactionService()) {
    self.view = view
    self.crashlyticsService = crashlyticsService
    self.transactionService = transactionService
    self.federationService = federationService
    addObservers()
  }
  
  @objc func onDidChangeTransactionList(_ notification: Notification) {
    displayPendingTransactions(isResetData: true)
  }
 
  @objc func onDidChangeTransactionListAfterLeavingBackground(_ notification: Notification) {
    displayPendingTransactions(isResetData: true, didBecomeActive: true)
  }
  
  @objc func onDidRemoveTransaction(_ notification: Notification) {
    displayPendingTransactions(isResetData: true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.view?.setHUDSuccessViewAfterRemoveOperation()
    }
  }
  
  @objc func onDidJWTTokenUpdate(_ notification: Notification) {
    displayPendingTransactions(isResetData: true)
  }
  
  @objc func onDidNicknameUpdate(_ notification: Notification) {
    displayPendingTransactions(isResetData: true)
  }
}

// MARK: - TransactionImportDelegate

extension TransactionListPresenterImpl: TransactionImportDelegate {
  func submitTransaction(with xdr: String) {
    guard let transactionEnvelopeXDR = try? TransactionEnvelopeXDR(xdr: xdr) else {
      return
    }
    
    transactionService.getSignedAccounts { result in
      switch result {
      case .success(let accounts):
        let accountId = TransactionHelper.getAccountId(signedAccounts: accounts, transactionEnvelopeXDR: transactionEnvelopeXDR)
        let domain = TransactionHelper.getManageDataOperationDomain(from: xdr)
        let authEndpoint = TransactionHelper.getManageDataOperationAuthEndpointWithPrefix(from: xdr)
        let webAuthenticator = WebAuthenticator(authEndpoint: authEndpoint, network: .public, serverSigningKey: transactionEnvelopeXDR.txSourceAccountId, serverHomeDomain: domain)
       // webAuthenticator.ignoreTimebounds = true
        
        let result = webAuthenticator.isValidChallenge(transactionEnvelopeXDR: transactionEnvelopeXDR, userAccountId: accountId, serverSigningKey: transactionEnvelopeXDR.txSourceAccountId)
        switch result {
        case .success:
          var transaction = Transaction()
          transaction.xdr = xdr
          transaction.transactionType = .authChallenge
          self.transitionToTransactionDetailsScreenFromImport(transaction: transaction)
        case .failure:
          var transaction = Transaction()
          transaction.xdr = xdr
          self.transitionToTransactionDetailsScreenFromImport(transaction: transaction)
        }
      case .failure(let error):
        var transaction = Transaction()
        transaction.xdr = xdr
        self.transitionToTransactionDetailsScreenFromImport(transaction: transaction)
        Logger.networking.error("Couldn't get signed accounts with error: \(error)")
      }
    }
  }
}

// MARK: - TransactionListPresenter

extension TransactionListPresenterImpl: TransactionListPresenter {
  
  func tableViewReachedBottom() {
    displayPendingTransactions()
  }
  
  func importXDRButtonWasPressed() {
    transitionToTransactionImport()
  }
  
  func clearAllTransactions() {
    view?.setProgressAnimationAfterDelete(isEnabled: true)
    transactionService.cancelAllTransaction { result in
      switch result {
      case .success:
        self.view?.setClearButton(isHidden: true)
        self.view?.setProgressAnimationAfterDelete(isEnabled: false)
        NotificationCenter.default.post(name: .didChangeTransactionList, object: nil)
      case .failure(let error):
        self.view?.setProgressAnimationAfterDelete(isEnabled: false)
        self.view?.setErrorAlert(for: error)
      }
    }
  }
  
  func clearInvalidTransactions() {
    view?.setProgressAnimationAfterDelete(isEnabled: true)
    transactionService.cancelOutdatedTransaction { result in
      switch result {
      case .success:
        let isHidden = self.transactionList.isEmpty
        self.view?.setClearButton(isHidden: isHidden)
        self.view?.setProgressAnimationAfterDelete(isEnabled: false)
        NotificationCenter.default.post(name: .didChangeTransactionList, object: nil)
      case .failure(let error):
        self.view?.setProgressAnimationAfterDelete(isEnabled: false)
        self.view?.setErrorAlert(for: error)
      }
    }
  }
  
  func transactionListViewDidLoad() {
    guard let viewController = view as? UIViewController else { return }
   //guard UtilityHelper.isTokenUpdated(view: viewController) else { return }
    
    if ConnectionHelper.checkConnection(viewController) {
      displayPendingTransactions()
    }
  }
  
  func transactionListViewDidAppear() {
//    guard let viewController = view as? UIViewController else { return }
//    guard UtilityHelper.isTokenUpdated(view: viewController) else { return }
  }
  
  func transactionWasSelected(with index: Int) {
    transitionToTransactionDetailsScreenFromList(by: index)
  }
  
  func pullToRefreshWasActivated() {
    displayPendingTransactions(isResetData: true)
  }
}

// MARK: - Private

private extension TransactionListPresenterImpl {
  
  func addObservers() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidRemoveTransaction(_:)),
                                           name: .didRemoveTransaction,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidChangeTransactionList(_:)),
                                           name: .didChangeTransactionList,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                          selector: #selector(onDidChangeTransactionListAfterLeavingBackground(_:)),
                                          name: UIApplication.didBecomeActiveNotification,
                                          object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidChangeTransactionList(_:)),
                                           name: .didChangeSignerDetails,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidJWTTokenUpdate(_:)),
                                           name: .didJWTTokenUpdate,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidNicknameUpdate(_:)),
                                           name: .didNicknameSet,
                                           object: nil)
  }
  
  func setStatus(_ status: TaskStatus , didBecomeActive: Bool = false) {
    guard status != transactionListStatus else {
      return
    }
    
    transactionListStatus = status
    view?.setProgressAnimation(isEnabled: status == .loading, didBecomeActive: didBecomeActive)
  }
  
  func getOperationType(from operationNames: [String]) -> String {
    guard !operationNames.isEmpty else { return "none" }
    let operationType = operationNames.count == 1 ? operationNames.first! : "\(operationNames.count) operations"
    
    return operationType
  }
  
  func displayPendingTransactions(isResetData: Bool = false, didBecomeActive: Bool = false) {
    guard let viewController = view as? UIViewController else { return }
    guard UtilityHelper.isTokenUpdated(view: viewController) else {
      self.view?.setProgressAnimationAfterError()
      return
    }
    if isResetData { currentPageNumber = 1 }
    guard transactionListStatus == .ready, let pageNumber = currentPageNumber, ConnectionHelper.isConnectedToNetwork() else {
      view?.setProgressAnimation(isEnabled: false, didBecomeActive: false)
      return
    }
    
    self.storageSigners = storage.retrieveSigners() ?? []
    setStatus(.loading, didBecomeActive: didBecomeActive)
    transactionService.getPendingTransactionList(page: pageNumber) { result in
      switch result {
      case .success(let response):
        let newTransactions = response.results
        self.view?.setClearButton(isHidden: newTransactions.isEmpty)
        self.currentPageNumber = response.hasNextPage() ? pageNumber + 1 : nil
        
        let cellViewModels = self.getCellViewModels(transactions: newTransactions, with: self.transactionList.count)
        if isResetData {
          self.transactionList = newTransactions
        } else {
          self.transactionList.append(contentsOf: newTransactions)
        }
        self.view?.setTransactionList(viewModels: cellViewModels, isResetData: isResetData)
        self.setStatus(.ready, didBecomeActive: didBecomeActive)
      case .failure(let error):
        self.setStatus(.ready, didBecomeActive: didBecomeActive)
        self.crashlyticsService.recordCustomException(error)
        self.view?.setErrorAlert(for: error)
      }
    }
  }
  
  func getCellViewModels(transactions: [Transaction], with indexOffset: Int) -> [TransactionListTableViewCell.ViewModel] {
    var cellViewModels = [TransactionListTableViewCell.ViewModel]()
    
    for (index, transaction) in transactions.enumerated() {
      var cell = createCellViewModel(from: transaction)
      cell.federation = getFederation(by: cell.sourceAccount, with: indexOffset + index)
      cellViewModels.append(cell)
    }
    
    return cellViewModels
  }
  
  func createCellViewModel(from transaction: Transaction) -> TransactionListTableViewCell.ViewModel {
    guard let xdr = transaction.xdr else { fatalError() }
    var sourceAccount = "undefined"
    
    var operationNames: [String] = []
    do {
      let envelopeXDR = try TransactionEnvelopeXDR(xdr: xdr)
      operationNames = try TransactionHelper.getListOfOperationNames(from: envelopeXDR, transactionType: transaction.transactionType)
      sourceAccount = envelopeXDR.txSourceAccountId
    } catch {
      crashlyticsService.recordCustomException(error)
      Logger.transactions.error("Couldn't get transaction with error: \(error)")
    }
    
    let operationType = getOperationType(from: operationNames)
    
    var operationDate: String = "invalid date"
    if let transactionDate = transaction.addedAt {
      operationDate = TransactionHelper.getValidatedDateForList(from: transactionDate)
    }
    
    let isTransactionValid = transaction.sequenceOutdatedAt == nil ? true : false
    
    return TransactionListTableViewCell.ViewModel(date: operationDate,
                                                  operationType: operationType,
                                                  sourceAccount: sourceAccount,
                                                  federation: nil,
                                                  isTransactionValid: isTransactionValid)
  }
  
  func getFederation(by publicKey: String, with cellIndex: Int) -> String? {
    if let account = storageSigners.first(where: { $0.address == publicKey }) {
      if let nickName = account.nickname, !nickName.isEmpty {
        return nickName
      } else {
        if let federation = account.federation, !federation.isEmpty {
          return federation
        } else {
          tryToLoadFederation(by: publicKey, for: cellIndex)
          return nil
        }
      }
    } else {
      guard let account = CoreDataStack.shared.fetch(Account.fetchBy(publicKey: publicKey)).first else {
        tryToLoadFederation(by: publicKey, for: cellIndex)
        return nil
      }
      return account.federation
    }
  }
  
  func tryToLoadFederation(by publicKey: String, for index: Int) {
    federationService.getFederation(for: publicKey) { result in
      switch result {
      case .success(let account):
        if let federation = account.federation {
          self.view?.updateFederataionAddress(federation, for: index)
        }
      case .failure(let error):
        Logger.home.error("Couldn't get federation for \(publicKey) with error: \(error)")
      }
    }
  }
}

// MARK: - Transitions

extension TransactionListPresenterImpl {
  private func transitionToTransactionImport() {
    let transactionImportViewController = TransactionImportViewController.createFromStoryboard()
    transactionImportViewController.delegate = self
    
    let transactionListViewController = view as! TransactionListViewController
    transactionListViewController.navigationController?.present(transactionImportViewController, animated: true, completion: nil)
  }
  
  private func transitionToTransactionDetailsScreenFromList(by index: Int) {
    let transactionDetailsViewController = TransactionDetailsViewController.createFromStoryboard()
    
    transactionDetailsViewController.presenter =
      TransactionDetailsPresenterImpl(view: transactionDetailsViewController,
                                      transaction: transactionList[index],
                                      type: .standard)
    Logger.transactionDetails.debug("Transaction: \(transactionList[index])")
    transactionDetailsViewController.presenter.transactionListIndex = index
    
    let transactionListViewController = view as! TransactionListViewController
    transactionListViewController.navigationController?.pushViewController(transactionDetailsViewController, animated: true)
  }
  
  private func transitionToTransactionDetailsScreenFromImport(transaction: Transaction) {
    let transactionDetailsViewController = TransactionDetailsViewController.createFromStoryboard()
    
    transactionDetailsViewController.presenter = TransactionDetailsPresenterImpl(view: transactionDetailsViewController,
                                                                                 transaction: transaction,
                                                                                 type: .imported)
    let transactionListViewController = view as! TransactionListViewController
    transactionListViewController.navigationController?.pushViewController(transactionDetailsViewController, animated: true)
  }
}
