import UIKit

class TransactionListViewController: UIViewController {

  var presenter: TransactionListPresenter!
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var importButton: UIButton!
  
  lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self,
                             action: #selector(pullToRefresh(_:)),
                             for: UIControl.Event.valueChanged)
    return refreshControl
  }()
  
  let progressHUD = ProgressHUD()
  var emptyStateLabel: UILabel?
  
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
  
  private func clearWaitingAnimation() {
    refreshControl.endRefreshing()
    progressHUD.remove()
  }
  
  private func setEmptyStateLabel() {
    emptyStateLabel = UILabel()
    
    guard let emptyStateLabel = emptyStateLabel else {
      return
    }
    
    view.addSubview(emptyStateLabel)
    
    emptyStateLabel.text = L10n.textEmptyStateTransactions
    emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
    emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }
  
  func removeEmptyStateLabel() {
    emptyStateLabel?.removeFromSuperview()
  }
}

// MARK: - TransactionListView

extension TransactionListViewController: TransactionListView {
  
  func deleteRow(by index: Int, isEmpty: Bool) {
    tableView.beginUpdates()
    tableView.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .right)
    tableView.endUpdates()
    
    if isEmpty {
      setEmptyStateLabel()
    }
  }
  
  func setTransactionList(isEmpty: Bool) {
    tableView.delegate = self
    tableView.dataSource = self
    clearWaitingAnimation()
    
    if isEmpty {
      setEmptyStateLabel()
    }
  }
  
  func reloadTransactionList(isEmpty: Bool) {
    tableView.reloadData()
    clearWaitingAnimation()
    
    isEmpty ? setEmptyStateLabel(): removeEmptyStateLabel()
  }
  
  func setProgressAnimation() {
    progressHUD.display(onView: view)
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
    
    let borderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 81))
    borderView.backgroundColor = Asset.Colors.white.color
    borderView.clipsToBounds = true
    borderView.layer.cornerRadius = 6
    borderView.layer.borderWidth = 1
    borderView.layer.borderColor = Asset.Colors.cellBorder.color.cgColor
    
    borderView.layer.addBorder(edge: .left, color: Asset.Colors.main.color, thickness: 5)
    
    cell.content.layer.shadowColor = UIColor.black.cgColor
    cell.content.layer.shadowOffset = CGSize(width: 0, height: 2)
    cell.content.layer.shadowOpacity = 0.1
    cell.content.layer.shadowRadius = 2
    
    cell.content.addSubview(borderView)
    cell.content.sendSubviewToBack(borderView)
    
    cell.selectionStyle = UITableViewCell.SelectionStyle.none
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    presenter.transactionWasSelected(with: indexPath.item)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 88
  }
  
}
