import Foundation
import stellarsdk

protocol HomeView: class {
  func setTransactionNumber(_ number: Int)
  func setPublicKey(_ publicKey: String)
  func setSignerDetails(_ signedAccounts: [SignedAccounts])
  func setProgressAnimationForTransactionNumber(isEnabled: Bool)
  func setProgressAnimationForSignerDetails(isEnabled: Bool)
  func setCopyHUD()
}

protocol HomePresenter {
  func homeViewDidLoad()
  func copyKeyButtonWasPressed()
  func updateSignerDetails()
}

class HomePresenterImpl: HomePresenter {
  
  fileprivate weak var view: HomeView?
  private let transactionService: TransactionService
  private let vaultStorage: VaultStorage
  
  private var publicKey: String?
  
  init(view: HomeView,
       transactionService: TransactionService = TransactionService(),
       vaultStorage: VaultStorage = VaultStorage()) {
    self.view = view
    self.transactionService = transactionService
    self.vaultStorage = vaultStorage
    
    NotificationCenter.default.addObserver(self, selector: #selector(onDidChangeTransactionList(_:)), name: .didChangeTransactionList, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onDidRemoveTransaction(_:)), name: .didRemoveTransaction, object: nil)
  }
  
  @objc func onDidRemoveTransaction(_ notification: Notification) {
    displayTransactionNumber()
  }
  
  @objc func onDidChangeTransactionList(_ notification: Notification) {
    displayTransactionNumber()
  }
  
  // MARK: - HomePresenter
  
  func homeViewDidLoad() {
    guard let viewController = view as? UIViewController else {
      return
    }
    
    if ConnectionHelper.checkConnection(viewController) {
      displayTransactionNumber()
      displayPublicKey()
    }
  }    
  
  func copyKeyButtonWasPressed() {
    if let publicKey = publicKey {
      UIPasteboard.general.string = publicKey
      view?.setCopyHUD()
    }
  }
  
  func updateSignerDetails() {
    displaySignerDetails()
  }
  
  // MARK: - HomeView
  
  func displayPublicKey() {
    guard let publicKeyFromKeychain = vaultStorage.getPublicKeyFromKeychain() else { return }
    view?.setPublicKey(publicKeyFromKeychain)
    publicKey = publicKeyFromKeychain
  }
  
  func displayTransactionNumber() {
    view?.setProgressAnimationForTransactionNumber(isEnabled: true)
    transactionService.getNumberOfTransactions() { result in
      switch result {
      case .success(let numberOfTransactions):
        self.view?.setTransactionNumber(numberOfTransactions)
        self.view?.setProgressAnimationForTransactionNumber(isEnabled: false)
      case .failure(let serverRequestError):
        switch serverRequestError {
        case ServerRequestError.needRepeatRequest:
          self.displayTransactionNumber()
        default:
          self.view?.setProgressAnimationForTransactionNumber(isEnabled: false)
          print("Error:: \(serverRequestError)")
        }
      }
    }
  }
  
  func displaySignerDetails() {
    view?.setProgressAnimationForSignerDetails(isEnabled: true)
    transactionService.getSignedAccounts() { result in
      switch result {
      case .success(let signedAccounts):
        self.view?.setSignerDetails(signedAccounts)
        self.view?.setProgressAnimationForSignerDetails(isEnabled: false)
      case .failure(let error):
        print("error: \(error)")
        self.view?.setProgressAnimationForSignerDetails(isEnabled: false)
      }
    }
  }
}
