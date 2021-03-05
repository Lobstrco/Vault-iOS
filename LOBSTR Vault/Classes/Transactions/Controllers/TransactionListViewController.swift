import PKHUD
import UIKit

class TransactionListViewController: UIViewController {
  var presenter: TransactionListPresenter!
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var importButton: UIButton!
  @IBOutlet var clearButton: UIBarButtonItem!
  @IBOutlet var emptyStateView: UIView!
  @IBOutlet var emptyStateLabel: UILabel!
  
  @IBOutlet var activityIndicator: UIActivityIndicatorView! {
    didSet {
      activityIndicator.style = .whiteLarge
      activityIndicator.color = Asset.Colors.main.color
      activityIndicator.hidesWhenStopped = true
    }
  }
  
  private var emptyState: UIView { return emptyStateView }
  
  private lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self,
                             action: #selector(pullToRefresh),
                             for: UIControl.Event.valueChanged)
    return refreshControl
  }()
  
  private let progressHUD = ProgressHUD()
  private var transactionCellViewModels: [TransactionListTableViewCell.ViewModel] = []
  
  let spinner = UIActivityIndicatorView(style: .whiteLarge)
  private var lastContentOffset: CGFloat = 0
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if #available(iOS 10.0, *) {
      tableView.refreshControl = refreshControl
    } else {
      tableView.addSubview(refreshControl)
    }
    
    tableView.contentInset = UIEdgeInsets(top: .zero,
                                          left: .zero,
                                          bottom: 70.0,
                                          right: .zero)
    
    presenter = TransactionListPresenterImpl(view: self)
    
    setAppearance()
    setStaticStrings()
    
    presenter.transactionListViewDidLoad()
    progressHUD.display(onView: view)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if UtilityHelper.jwtTokenExpired() {
      tableView.refreshControl = nil
    } else {
      tableView.refreshControl = refreshControl
    }
    navigationController?.setStatusBar(backgroundColor: Asset.Colors.background.color)
    navigationController?.navigationBar.barTintColor = Asset.Colors.background.color
    tabBarController?.tabBar.isHidden = false
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presenter.transactionListViewDidAppear()
  }
  
  // MARK: - IBActions
  
  @IBAction func importXDRButtonAction(_ sender: Any) {
    presenter.importXDRButtonWasPressed()
  }
  
  @IBAction func clearButtonAction(_ sender: Any) {
    let alert = UIAlertController(title: L10n.textClearTransactionsTitle,
                                  message: L10n.textClearTransactionsDescription,
                                  preferredStyle: .alert)
    
    let removeInvalidAction = UIAlertAction(title: L10n.buttonTitleRemoveInvalid,
                                            style: .default) { _ in
      self.presenter.clearInvalidTransactions()
    }
    
    let removeAllAction = UIAlertAction(title: L10n.buttonTitleRemoveAll,
                                        style: .default) { _ in
      self.presenter.clearAllTransactions()
    }
    
    let cancelAction = UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel)
    alert.addAction(cancelAction)
    alert.addAction(removeInvalidAction)
    alert.addAction(removeAllAction)
    present(alert, animated: true, completion: nil)
  }
  
  // MARK: - Private
  
  @objc private func pullToRefresh() {
    presenter.pullToRefreshWasActivated()
  }
  
  private func setStaticStrings() {
    navigationItem.title = L10n.navTitleTransactions
    emptyStateLabel.text = L10n.textEmptyStateTransactions
    clearButton.title = L10n.buttonTitleClear
  }
  
  private func setAppearance() {
    self.navigationItem.rightBarButtonItem = nil
    importButton.layer.cornerRadius = 56 / 2
    refreshControl.tintColor = Asset.Colors.main.color
    spinner.color = Asset.Colors.main.color
    spinner.hidesWhenStopped = true
    
    configureTableView()
  }
  
  private func configureTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = spinner
    tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
  }
}

// MARK: - TransactionListView

extension TransactionListViewController: TransactionListView {
  func setProgressAnimation(isEnabled: Bool, didBecomeActive: Bool) {
    DispatchQueue.main.async {
      if didBecomeActive {
        if !isEnabled {
          self.activityIndicator.stopAnimating()
        } else {
          self.emptyState.isHidden = true
          self.transactionCellViewModels.removeAll()
          self.tableView.reloadData()
          self.activityIndicator.startAnimating()
        }
      } else {
        if !isEnabled {
          self.progressHUD.remove()
          self.spinner.stopAnimating()
        }
      }
    }
  }
  
  func setProgressAnimationAfterDelete(isEnabled: Bool) {
    DispatchQueue.main.async {
      if !isEnabled {
        self.activityIndicator.stopAnimating()
      } else {
        self.transactionCellViewModels.removeAll()
        self.tableView.reloadData()
        self.activityIndicator.startAnimating()
      }
    }
  }
  
  func setProgressAnimationAfterError() {
    DispatchQueue.main.async {
      if self.refreshControl.isRefreshing == true {
        self.refreshControl.endRefreshing()
      }
      self.tableView.reloadData()
      self.spinner.stopAnimating()
    }
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
    if refreshControl.isRefreshing == true {
      DispatchQueue.main.async {
        self.refreshControl.endRefreshing()
      }
    }
    spinner.stopAnimating()
    emptyState.isHidden = !viewModels.isEmpty
  }
  
  func setImportXDRPopover(_ popover: CustomPopoverViewController) {
    present(popover, animated: true, completion: nil)
  }
  
  func setErrorAlert(for error: Error) {
    DispatchQueue.main.async {
      self.refreshControl.endRefreshing()
      self.spinner.stopAnimating()
      UIAlertController.defaultAlert(for: error, presentingViewController: self)
    }
  }
  
  func setClearButton(isHidden: Bool) {
    self.navigationItem.rightBarButtonItem = isHidden ? nil : clearButton
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
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let height = scrollView.frame.size.height
    let contentYoffset = scrollView.contentOffset.y
    let distanceFromBottom = scrollView.contentSize.height - contentYoffset
    if (self.lastContentOffset < scrollView.contentOffset.y), distanceFromBottom < height, !spinner.isAnimating {
      spinner.startAnimating()
      presenter.tableViewReachedBottom()
    }
  }
}
