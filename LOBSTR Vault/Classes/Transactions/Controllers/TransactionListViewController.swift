import UIKit
import PKHUD

class TransactionListViewController: UIViewController {

  var presenter: TransactionListPresenter!
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var importButton: UIButton!
  @IBOutlet var clearButton: UIBarButtonItem!
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
  
  var isPullingRefresh = false
  var isThereMoreContent = true
  var isFirstLoading = true
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.addSubview(self.refreshControl)
    tableView.contentInset = UIEdgeInsets(top: .zero,
                                          left: .zero,
                                          bottom: 70.0,
                                          right: .zero)
    
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
  
  @IBAction func clearButtonAction(_ sender: Any) {
    let alert = UIAlertController(title: L10n.textClearInvalidTransactionsTitle,
                                  message: L10n.textClearInvalidTransactionsDescription,
                                  preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: L10n.buttonTitleOk,
                                       style: .default) { _ in
                                        self.presenter.clearButtonWasPressed()
    }
    let cancelAction = UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel)
    alert.addAction(okAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  // MARK: - Private
  
  @objc private func pullToRefresh(_ refreshControl: UIRefreshControl) {
    isPullingRefresh = true
    presenter.pullToRefreshWasActivated()
  }
  
  private func setStaticStrings() {
    navigationItem.title = L10n.navTitleTransactions
    emptyStateLabel.text = L10n.textEmptyStateTransactions
    clearButton.title = L10n.buttonTitleClear
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
    HUD.flash(.labeledSuccess(title: nil,
                              subtitle: L10n.textDeclinedTransaction), delay: 1.5)
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
  
  func setTransactionList(isEmpty: Bool, isThereMoreContent: Bool) {
    self.isThereMoreContent = isThereMoreContent
    tableView.delegate = self
    tableView.dataSource = self
    tableView.reloadData()
    
    emptyState.isHidden = !isEmpty
  }
  
  func reloadTransactionList(isEmpty: Bool, isThereMoreContent: Bool) {
    self.isThereMoreContent = isThereMoreContent
//    isFirstLoading = true
    tableView.reloadData()
    emptyState.isHidden = !isEmpty
  }
  
  func setFirstLoadingStatus(_ status: Bool) {
    isFirstLoading = status
  }
  
  func setProgressAnimation(isEnabled: Bool) {
    if isEnabled {
      if !isPullingRefresh {
        progressHUD.display(onView: view)
      }
    } else {
      refreshControl.endRefreshing()
      isPullingRefresh = false
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
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if isThereMoreContent, indexPath.row + 1 == presenter.countOfTransactions {
      guard !isFirstLoading else {
        isFirstLoading = false
        return
      }      
      presenter.tableViewReachedBottom()
    }
  }
}
