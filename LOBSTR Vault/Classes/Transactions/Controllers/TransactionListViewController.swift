import UIKit

class TransactionListViewController: UIViewController, TransactionListView {

  var presenter: TransactionListPresenter!
  
  @IBOutlet var tableView: UITableView!
  
  // MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter = TransactionListPresenterImpl(view: self)
    presenter.transactionListViewDidLoad()
    
    configureTableView()
  }
  
  // MARK: - TransactionListView
  
  func displayTransactionList() {
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.reloadData()
  }
  
  // MARK: - Public Methods
  
  func configureTableView() {
    tableView.tableFooterView = UIView()
  }
}

// MARK: - UITableView

extension TransactionListViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.countOfTransactions
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "TransactionListTableViewCell") as! TransactionListTableViewCell
    presenter.configure(cell: cell, forRow: indexPath.item)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    presenter.transactionWasSelected(with: indexPath.item)
  }  
  
}
