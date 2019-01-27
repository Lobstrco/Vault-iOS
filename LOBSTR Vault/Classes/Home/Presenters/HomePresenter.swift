import Foundation
import stellarsdk

protocol HomeView: class {
  func setTransactionNumber(_ number: Int)
  func setPublicKey(_ publicKey: String)
  func setSignerDetails(_ signedAccounts: [SignedAccounts])
}

protocol HomePresenter {
  func homeViewDidLoad()
  func copyKeyButtonWasPressed()
}

class HomePresenterImpl: HomePresenter {
  
  fileprivate weak var view: HomeView?
  private let homeService: HomeService
  private let vaultStorage: VaultStorage
  
  private var publicKey: String?
  
  init(view: HomeView,
       homeService: HomeService = HomeService(),
       vaultStorage: VaultStorage = VaultStorage()) {
    self.view = view
    self.homeService = homeService
    self.vaultStorage = vaultStorage
    
    NotificationCenter.default.addObserver(self, selector: #selector(onDidChangeTransactionList(_:)), name: .didChangeTransactionList, object: nil)
  }
  
  @objc func onDidChangeTransactionList(_ notification: Notification) {
    displayTransactionNumber()
  }
  
  // MARK: - HomePresenter
  
  func homeViewDidLoad() {
    displayTransactionNumber()
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
    homeService.getNumberOfTransactions() { result in
      switch result {
      case .success(let numberOfTransactions):
        self.view?.setTransactionNumber(numberOfTransactions)
        self.displaySignerDetails()
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
    homeService.getSignedAccounts() { result in
      switch result {
      case .success(let signedAccounts):
        self.view?.setSignerDetails(signedAccounts)
      case .failure(let error):
        print("error: \(error)")
      }
    }
  }
}
