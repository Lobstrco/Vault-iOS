import Foundation
import stellarsdk

protocol HomeView: class {
  func displayTransactionNumber(_ number: Int)
}

protocol HomePresenter {
  func homeViewDidLoad()
}

class HomePresenterImpl: HomePresenter {
  
  fileprivate weak var view: HomeView?
  
  init(view: HomeView) {
    self.view = view
  }
  
  // MARK: - HomePresenter
  
  func homeViewDidLoad() {
    displayTransactionNumber()    
  }
  
  // MARK: - HomeView
  
  func displayTransactionNumber() {
    
    let apiLoader = APIRequestLoader<PendingTransactionListRequest>(apiRequest: PendingTransactionListRequest())

    apiLoader.loadAPIRequest(requestData: nil) { result in
      switch result {
      case .success(let paginationResponse):
        self.view?.displayTransactionNumber(paginationResponse.count)
      case .failure(let serverRequestError):
        switch serverRequestError {
        case ServerRequestError.needRepeatRequest:
          self.displayTransactionNumber()
        default:
          print("Error:: \(serverRequestError)")
        }
      }
    }
  }
  
  
}