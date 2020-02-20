import UIKit
import PKHUD

class TransactionListViewController: UIViewController {

  var presenter: TransactionListPresenter!
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var importButton: UIButton!
  @IBOutlet var clearButton: UIBarButtonItem!
  @IBOutlet var emptyStateLabel: UILabel!
  
  private var emptyState: UILabel {
    get { return emptyStateLabel }
  }
  
  private lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self,
                             action: #selector(pullToRefresh),
                             for: UIControl.Event.valueChanged)
    return refreshControl
  }()
  
  private let progressHUD = ProgressHUD()
  private var transactionCellViewModels: [TransactionListTableViewCell.ViewModel] = []
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.addSubview(self.refreshControl)
    tableView.contentInset = UIEdgeInsets(top: .zero,
                                          left: .zero,
                                          bottom: 70.0,
                                          right: .zero)
    
    presenter = TransactionListPresenterImpl(view: self)
    
    setAppearance()
    setStaticStrings()
    
    presenter.transactionListViewDidLoad()
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
  
  @objc private func pullToRefresh() {
    refreshControl.endRefreshing()
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
}

// MARK: - TransactionListView

extension TransactionListViewController: TransactionListView {
  
  func setProgressAnimation(isEnabled: Bool) {
    isEnabled ? progressHUD.display(onView: view) : progressHUD.remove()
  }
  
  func setHUDSuccessViewAfterRemoveOperation() {
    HUD.flash(.labeledSuccess(title: nil,
                              subtitle: L10n.textDeclinedTransaction), delay: 1.5)
  }
  
  func updateFederataionAddress(_ address: String, for indexItem: Int) {
    UIView.performWithoutAnimation {
      if transactionCellViewModels[safe: indexItem] != nil {
        transactionCellViewModels[indexItem].federation = address
        tableView.reloadRows(at: [IndexPath(row: indexItem, section: 0)], with: .none)
      }
    }
  }
  
  func setTransactionList(viewModels: [TransactionListTableViewCell.ViewModel], isResetData: Bool) {
    if isResetData {
      transactionCellViewModels = viewModels
    } else {
      transactionCellViewModels.append(contentsOf: viewModels)
    }
    
    tableView.reloadData()
    refreshControl.endRefreshing()
    emptyState.isHidden = !viewModels.isEmpty
  }
  
  func setImportXDRPopover(_ popover: CustomPopoverViewController) {
    present(popover, animated: true, completion: nil)    
  }
  
  func setErrorAlert(for error: Error) {
    refreshControl.endRefreshing()
    UIAlertController.defaultAlert(for: error, presentingViewController: self)
  }
}

// MARK: - UITableView

extension TransactionListViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return transactionCellViewModels.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionListTableViewCell") as! TransactionListTableViewCell
    cell.viewModel = transactionCellViewModels[indexPath.item]
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    presenter.transactionWasSelected(with: indexPath.item)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 88
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row + 1 == transactionCellViewModels.count {
      presenter.tableViewReachedBottom()
    }
  }
}
