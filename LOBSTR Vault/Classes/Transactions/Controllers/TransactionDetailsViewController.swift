import UIKit

class TransactionDetailsViewController: UIViewController, TransactionDetailsView, StoryboardCreation {
  
  static var storyboardType: Storyboards = .transactions
  
  var presenter = TransactionDetailsPresenterImpl()
  
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - Lifecycle
  
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
  
  // MARK: - IBActions
  
  @IBAction func confirmButtonAction(_ sender: Any) {
    presenter.confirmButtonWasPressed()
  }
  
  @IBAction func DenyButtonAction(_ sender: Any) {
    presenter.denyButtonWasPressed()
  }
  
  // MARK: - TransactionDetailsView
  
  func setOperationList() {
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.reloadData()
  }
  
  func setConfirmationAlert() {
    let alert = UIAlertController(title: "Are you sure?", message: "Are you sure you want to deny the operation?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Deny", style: .destructive, handler: { _ in
      self.presenter.denyOperationWasConfirmed()
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  // MARK: - Public
  
  func configureTableView() {
    tableView.tableFooterView = UIView()
  }
}

// MARK: - UITableView

extension TransactionDetailsViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.operationNumber
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "OperationTableViewCell", for: indexPath) as! OperationTableViewCell
    cell.setOperationTitle(presenter.operationNames[indexPath.item])
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    presenter.operationWasSelected(by: indexPath.item)
  }  
}
