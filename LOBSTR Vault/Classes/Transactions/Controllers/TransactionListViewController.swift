import UIKit

class TransactionListViewController: UIViewController {

  var presenter: TransactionListPresenter!
  
  @IBOutlet var tableView: UITableView!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter = TransactionListPresenterImpl(view: self)
    presenter.transactionListViewDidLoad()
    
    configureTableView()
  }
  
  // MARK: - Public
  
  func configureTableView() {
    tableView.tableFooterView = UIView()
  }
}

// MARK: - TransactionListView

extension TransactionListViewController: TransactionListView {
  
  func setTransactionList() {
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.reloadData()
  }
  
  func setErrorAlert(for error: Error) {
    UIAlertController.defaultAlert(for: error, presentingViewController: self)
  }
}

// MARK: - UITableView

extension TransactionListViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.countOfTransactions
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "TransactionListTableViewCell") as! TransactionListTableViewCell
    presenter.configure(cell, forRow: indexPath.item)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    presenter.transactionWasSelected(with: indexPath.item)
  }  
  
}
