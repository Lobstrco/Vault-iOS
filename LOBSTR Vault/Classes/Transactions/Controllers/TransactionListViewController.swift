import UIKit
import PKHUD

class TransactionListViewController: UIViewController {

  var presenter: TransactionListPresenter!
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var importButton: UIButton!
  @IBOutlet var emptyStateLabel: UILabel!
  
  var emptyState: UILabel {
    get { return emptyStateLabel }
  }
  
  lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self,
                             action: #selector(pullToRefresh(_:)),
                             for: UIControl.Event.valueChanged)
    return refreshControl
  }()
  
  let progressHUD = ProgressHUD()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.addSubview(self.refreshControl)
    
    presenter = TransactionListPresenterImpl(view: self)
    presenter.transactionListViewDidLoad()
    
    setAppearance()
    setStaticStrings()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    tabBarController?.tabBar.isHidden = false
  }
  
  // MARK: - IBActions
  
  @IBAction func importXDRButtonAction(_ sender: Any) {
    presenter.importXDRButtonWasPressed()
  }
  
  // MARK: - Private
  
  @objc private func pullToRefresh(_ refreshControl: UIRefreshControl) {
    presenter.pullToRefreshWasActivated()
  }
  
  private func setStaticStrings() {
    navigationItem.title = L10n.navTitleTransactions
    emptyStateLabel.text = L10n.textEmptyStateTransactions
  }
  
  private func setAppearance() {
    configureTableView()
    importButton.layer.cornerRadius = 56 / 2
    refreshControl.tintColor = Asset.Colors.main.color
  }
  
  private func configureTableView() {
    tableView.tableFooterView = UIView()
    tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
  }
  
  internal func setHUDSuccessViewAfterRemoveOperation() {
    HUD.flash(.labeledSuccess(title: nil, subtitle: L10n.textDeclinedTransaction), delay: 1.5)
  }
}

// MARK: - TransactionListView

extension TransactionListViewController: TransactionListView {
  
  func deleteRow(by index: Int, isEmpty: Bool) {
    tableView.beginUpdates()
    tableView.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .right)
    tableView.endUpdates()
    
    emptyState.isHidden = !isEmpty
  }
  
  func setTransactionList(isEmpty: Bool) {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.reloadData()
    
    emptyState.isHidden = !isEmpty
  }
  
  func reloadTransactionList(isEmpty: Bool) {
    tableView.reloadData()
    
    emptyState.isHidden = !isEmpty
  }
  
  func setProgressAnimation(isEnabled: Bool) {
    if isEnabled {
      progressHUD.display(onView: view)
    } else {
      refreshControl.endRefreshing()
      progressHUD.remove()
    }
  }
  
  func setImportXDRPopover(_ popover: CustomPopoverViewController) {
    present(popover, animated: true, completion: nil)    
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
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 88
  }
  
}
