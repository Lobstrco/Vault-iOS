import Foundation

protocol SignerDetailsView: class {
  func setAccountList(isEmpty: Bool)
  func setProgressAnimation()
}

protocol SignerDetailsPresenter {
  var countOfAccounts: Int { get }
  func configure(_ cell: SignerDetailsTableViewCell, forRow row: Int)
  func signerDetailsViewDidLoad()
}

class SignerDetailsPresenterImpl {
  
  var accounts: [SignedAccounts] = []
  
  private let homeService: HomeService
  
  fileprivate weak var view: SignerDetailsView?
  
  init(view: SignerDetailsView,
       homeService: HomeService = HomeService()) {
    self.view = view
    self.homeService = homeService
  }
  
  func displayAccountList() {
    view?.setProgressAnimation()
    homeService.getSignedAccounts() { result in
      switch result {
      case .success(let signedAccounts):
        self.accounts = signedAccounts        
        self.view?.setAccountList(isEmpty: self.accounts.isEmpty)
      case .failure(let error):
        print("error: \(error)")
      }
    }
  }
}

extension SignerDetailsPresenterImpl: SignerDetailsPresenter {
  
  var countOfAccounts: Int {
    return accounts.count
  }
  
  func configure(_ cell: SignerDetailsTableViewCell, forRow row: Int) {
    guard let address = accounts[row].address else {
      return
    }
    
    cell.setPublicKey(address)
  }
  
  func signerDetailsViewDidLoad() {
    displayAccountList()
  }
  
  
  
}
