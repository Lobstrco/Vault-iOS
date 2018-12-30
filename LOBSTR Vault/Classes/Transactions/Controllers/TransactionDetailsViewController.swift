import UIKit

class TransactionDetailsViewController: UIViewController, TransactionDetailsView, StoryboardCreation {
  
  static var storyboardType: Storyboards = .transactions
  
  var presenter = TransactionDetailsPresenterImpl()
  
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter.initData(view: self)
    presenter.transactionDetailsViewDidLoad()
    
    configureTableView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    tabBarController?.tabBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    tabBarController?.tabBar.isHidden = false
  }
  
  // MARK: - TransactionDetailsView
  
  func displayOperationList() {
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.reloadData()
  }
  
  // MARK: - Public Methods
  
  func configureTableView() {
    tableView.tableFooterView = UIView()
  }
}

extension TransactionDetailsViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.operationNumber
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "OperationTableViewCell", for: indexPath) as! OperationTableViewCell
    cell.setOperationTitle(presenter.operationNames[indexPath.item])
    
    return cell
  }  
  
}
