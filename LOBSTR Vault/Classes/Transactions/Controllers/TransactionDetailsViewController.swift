import UIKit
import PKHUD

class TransactionDetailsViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .transactions
  var presenter: TransactionDetailsPresenter!
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var confirmButton: UIButton!
  @IBOutlet weak var denyButton: UIButton!
  @IBOutlet weak var expiredErrorLabel: UILabel!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setStaticStrings()
    setAppearance()
    
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
  
  @IBAction func denyButtonAction(_ sender: Any) {
    presenter.denyButtonWasPressed()
  }
  
  // MARK: - Private
  
  private func setStaticStrings() {
    denyButton.setTitle(L10n.buttonTitleDeny, for: .normal)
  }
  
  private func configureTableView() {
    tableView.registerNibForHeaderFooter(SignersHeaderView.self)
    tableView.tableFooterView = UIView()
  }
  
  private func setAppearance() {
    AppearanceHelper.set(confirmButton, with: L10n.buttonTitleConfirm)
  }
}

// MARK: - TransactionDetailsView

extension TransactionDetailsViewController: TransactionDetailsView {
  
  func setTitle(_ title: String) {
    navigationItem.title = title
  }
  
  func setTableViewData() {
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.reloadData()
  }
  
  func disableBackButton() {
    navigationItem.hidesBackButton = true
  }
  
  func setConfirmationAlert() {
    let alert = UIAlertController(title: L10n.textDenyDialogTitle,
                                  message: L10n.textConfirmDialogDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleYes, style: .destructive, handler: { _ in
      self.presenter.confirmOperationWasConfirmed()
    }))
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  func setDenyingAlert() {
    let alert = UIAlertController(title: L10n.textDenyDialogTitle,
                                  message: L10n.textDenyDialogDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleYes, style: .destructive, handler: { _ in
      self.presenter.denyOperationWasConfirmed()
    }))
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  func setErrorAlert(for error: Error) {
    UIAlertController.defaultAlert(for: error, presentingViewController: self)
  }
  
  func setProgressAnimation(isEnable: Bool) {
    DispatchQueue.main.async {
      self.navigationItem.hidesBackButton = isEnable
      isEnable ? HUD.show(.labeledProgress(title: nil,
                                           subtitle: L10n.animationWaiting)) : HUD.hide()
    }
  }
  
  func registerTableViewCell(with cellName: String) {
    tableView.register(UINib(nibName: cellName, bundle: nil),
                       forCellReuseIdentifier: cellName)
  }
  
  func setConfirmButtonWithError(isInvalid: Bool) {
    guard isInvalid else {
      confirmButton.backgroundColor = Asset.Colors.main.color
      return
    }
    
    expiredErrorLabel.isHidden = false
    expiredErrorLabel.text = L10n.textTransactionInvalidError
    confirmButton.isEnabled = false
    confirmButton.backgroundColor = Asset.Colors.disabled.color
    confirmButton.setTitleColor(Asset.Colors.white.color, for: .normal)
  }
  
  func openTransactionListScreen() {
    navigationController?.popViewController(animated: true)
  }
}

// MARK: - UITableView

extension TransactionDetailsViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    // 1st section: operations
    // 2nd section: accepted/pending signatures
    return 2
  }
  
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    
    if section == 0 {
      guard presenter.numberOfOperation == 1 else {
        return presenter.numberOfOperation
      }
      
      return presenter.numberOfOperationDetails
    } else {
      return presenter.numberOfSigners
    }
  }
  
  func tableView(_ tableView: UITableView,
                 viewForHeaderInSection section: Int) -> UIView? {
    // Header View with number of accepted signatures.
    if section == 1 {
      let headerView: SignersHeaderView =
        tableView.dequeueReusableHeaderFooterView(withIdentifier: SignersHeaderView.reuseIdentifier) as! SignersHeaderView
      
      let text = "\(presenter.numberOfAcceptedSignatures) of \(presenter.numberOfSigners)"
      headerView.numberOfAcceptedSignaturesLabel.text = text
      return headerView
    }
    
    return nil
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if indexPath.section == 0 { // Operations
      guard presenter.numberOfOperation == 1 else {
        let cell: OperationTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        presenter.configure(cell, forRow: indexPath.row)
        return cell
      }
      
      let cell: OperationDetailsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
      presenter.configure(cell, forRow: indexPath.row)
      cell.selectionStyle = .none
      return cell
    } else { // Signers
      let cell: SignerTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
      presenter.configure(cell, forRow: indexPath.row)
      cell.selectionStyle = .none
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView,
                 didSelectRowAt indexPath: IndexPath) {
    guard presenter.numberOfOperation != 1 else {
      return
    }
    
    tableView.deselectRow(at: indexPath, animated: true)
    presenter.operationWasSelected(by: indexPath.item)
  }
  
  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50.0
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    
    if section == 0 {
      return CGFloat.zero
    } else {
      return 22.0
    }
  }
}
