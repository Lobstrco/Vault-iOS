import Foundation
import stellarsdk

protocol HomeView: class {
  func setTransactionNumber(_ number: Int)
  func setPublicKey(_ publicKey: String)
  func setSignerDetails(_ signedAccounts: [SignedAccounts])
  func setProgressAnimationForTransactionNumber()
  func setProgressAnimationForSignerDetails()
}

protocol HomePresenter {
  func homeViewDidLoad()
  func copyKeyButtonWasPressed()
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
    displayTransactionNumber()
    displaySignerDetails()
    displayPublicKey()
  }
  
  func copyKeyButtonWasPressed() {
    UIPasteboard.general.string = publicKey
  }
  
  // MARK: - HomeView
  
  func displayPublicKey() {
    guard let publicKeyFromKeychain = vaultStorage.getPublicKeyFromKeychain() else { return }
    view?.setPublicKey(publicKeyFromKeychain)
    publicKey = publicKeyFromKeychain
  }
  
  func displayTransactionNumber() {
    view?.setProgressAnimationForTransactionNumber()
    transactionService.getNumberOfTransactions() { result in
      switch result {
      case .success(let numberOfTransactions):
        self.view?.setTransactionNumber(numberOfTransactions)
      case .failure(let serverRequestError):
        switch serverRequestError {
        case ServerRequestError.needRepeatRequest:
          self.displayTransactionNumber()
        default:
          print("Error:: \(serverRequestError)")
        }
        break
      }
    }
  }
  
  func displaySignerDetails() {
    view?.setProgressAnimationForSignerDetails()
    transactionService.getSignedAccounts() { result in
      switch result {
      case .success(let signedAccounts):
        self.view?.setSignerDetails(signedAccounts)
      case .failure(let error):
        print("error: \(error)")
      }
    }
  }
}
