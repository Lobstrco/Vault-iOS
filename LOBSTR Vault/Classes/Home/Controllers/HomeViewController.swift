import UIKit

class HomeViewController: UIViewController, HomeView, StoryboardCreation {
  
  static var storyboardType: Storyboards = .home
  
  @IBOutlet weak var transactionNumber: UILabel!
  
  var presenter: HomePresenter!
  
  override func viewDidLoad() {
    super.viewDidLoad()
   
    presenter = HomePresenterImpl(view: self)
    presenter.homeViewDidLoad()
  }

  // MARK: - HomeView
  
  func displayTransactionNumber(_ number: Int) {
    transactionNumber.text = String(number)
  }
}
