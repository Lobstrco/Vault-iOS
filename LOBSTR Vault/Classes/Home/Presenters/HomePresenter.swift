import Foundation
import stellarsdk

protocol HomeView: class {
  func setTransactionNumber(_ number: Int)
  func setTransactionNumber(_ number: String)
  func setPublicKey(_ publicKey: String)
  func setSignerDetails(_ signedAccounts: [SignedAccounts])
  func setProgressAnimationForTransactionNumber(isEnabled: Bool)
  func setProgressAnimationForSignerDetails(isEnabled: Bool)
  func setCopyHUD()
}

protocol HomePresenter {
  func homeViewDidLoad()
  func copyKeyButtonWasPressed()
  func copySignerKeyButtonWasPressed()
  func updateSignerDetails()
}

class HomePresenterImpl: HomePresenter {
  
  fileprivate weak var view: HomeView?
  private let transactionService: TransactionService
  private let vaultStorage: VaultStorage
  
  private var publicKey: String?
  private var signerForKey: String?
  
  fileprivate var transactionNumberStatus: TaskStatus = .ready
  
  init(view: HomeView,
       transactionService: TransactionService = TransactionService(),
       vaultStorage: VaultStorage = VaultStorage()) {
    self.view = view
    self.transactionService = transactionService
    self.vaultStorage = vaultStorage
    
    addObservers()
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
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.displayTransactionNumber()
        self.displayPublicKey()
      }
    }
  }    
  
  func copyKeyButtonWasPressed() {
    if let publicKey = publicKey {
      UIPasteboard.general.string = publicKey
      view?.setCopyHUD()
    }
  }
  
  func copySignerKeyButtonWasPressed() {
    if let signerForKey = signerForKey {
      UIPasteboard.general.string = signerForKey
      view?.setCopyHUD()
    }
  }
  
  func updateSignerDetails() {
    displaySignerDetails()
  }
  
  // MARK: - Private
  
  private func addObservers() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidChangeTransactionList(_:)),
                                           name: .didChangeTransactionList,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidRemoveTransaction(_:)),
                                           name: .didRemoveTransaction,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidChangeTransactionList(_:)),
                                           name: UIApplication.didBecomeActiveNotification,
                                           object: nil)
  }
  
  private func setStatus(_ status: TaskStatus) {
    transactionNumberStatus = status
    
    if status == .loading {
      view?.setProgressAnimationForTransactionNumber(isEnabled: true)
    } else {
      view?.setProgressAnimationForTransactionNumber(isEnabled: false)
    }
  }
  
  // MARK: - HomeView
  
  func displayPublicKey() {
    guard let publicKeyFromKeychain = vaultStorage.getPublicKeyFromKeychain() else { return }
    view?.setPublicKey(publicKeyFromKeychain)
    publicKey = publicKeyFromKeychain
  }
  
  func displayTransactionNumber() {
    guard transactionNumberStatus == .ready else {
      return
    }
    
    setStatus(.loading)
    transactionService.getNumberOfTransactions() { result in
      switch result {
      case .success(let numberOfTransactions):
        self.view?.setTransactionNumber(numberOfTransactions)
        self.setStatus(.ready)
      case .failure(let serverRequestError):
        self.setStatus(.ready)
        switch serverRequestError {
        case ServerRequestError.needRepeatRequest:          
          self.displayTransactionNumber()
        default:
          self.view?.setTransactionNumber("-")
        }
      }
    }
  }
  
  func displaySignerDetails() {
    view?.setProgressAnimationForSignerDetails(isEnabled: true)
    transactionService.getSignedAccounts() { result in
      switch result {
      case .success(let signedAccounts):
        self.view?.setProgressAnimationForSignerDetails(isEnabled: false)
        self.view?.setSignerDetails(signedAccounts)
        UserDefaultsHelper.numberOfSignerAccounts = signedAccounts.count
        
        if signedAccounts.count == 1 {
          self.signerForKey = signedAccounts.first?.address
        }
      case .failure(_):        
        self.view?.setProgressAnimationForSignerDetails(isEnabled: false)
      }
    }
  }
}
