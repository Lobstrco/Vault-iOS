import UIKit

class TransactionDetailsViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .transactions
  var presenter: TransactionDetailsPresenter!
  
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
  
  // MARK: - Public
  
  func configureTableView() {
    tableView.tableFooterView = UIView()
  }
}

// MARK: - TransactionDetailsView

extension TransactionDetailsViewController: TransactionDetailsView {
  
  func setOperationList() {
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.reloadData()
  }
  
  func setConfirmationAlert() {
    let alert = UIAlertController(title: "DENY_TITLE".localized(), message: "DENY_MESSAGE".localized(), preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "DENY_TEXT".localized(), style: .destructive, handler: { _ in
      self.presenter.denyOperationWasConfirmed()
    }))
    
    alert.addAction(UIAlertAction(title: "CANCEL_TEXT".localized(), style: .cancel))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  func setErrorAlert(for error: Error) {
    UIAlertController.defaultAlert(for: error, presentingViewController: self)
  }
}

// MARK: - UITableView

extension TransactionDetailsViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.numberOfOperation
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "OperationTableViewCell", for: indexPath) as! OperationTableViewCell
    presenter.configure(cell, forRow: indexPath.item)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    presenter.operationWasSelected(by: indexPath.item)
  }  
}
