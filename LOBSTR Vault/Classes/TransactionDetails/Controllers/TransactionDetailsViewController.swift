import UIKit
import PKHUD

class TransactionDetailsViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .transactions
  var presenter: TransactionDetailsPresenter!
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var confirmButton: UIButton!
  @IBOutlet weak var denyButton: UIButton!
  @IBOutlet weak var expiredErrorLabel: UILabel!
  
  @IBOutlet weak var errorLabelHeightConstraint: NSLayoutConstraint!
  
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setStaticStrings()
    setAppearance()
    
    presenter.transactionDetailsViewDidLoad()    
    configureTableView()
    denyButton.layer.borderWidth = 1
    denyButton.layer.borderColor = Asset.Colors.red.color.cgColor
    denyButton.layer.cornerRadius = 4
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
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
  
  func reloadData() {
    tableView.reloadData()
  }
  
  func reloadSignerListRow(_ row: Int) {
    let indexPath = IndexPath(row: row, section: TransactionDetailsSectionType.signers.index)
    tableView.reloadRows(at: [indexPath], with: .automatic)
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
    errorLabelHeightConstraint.constant = 30
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
    return presenter.sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.sections[section].rows.count
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard presenter.sections[section].type == .signers else {
      return nil
    }
    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SignersHeaderView.reuseIdentifier) as! SignersHeaderView
    headerView.numberOfAcceptedSignaturesLabel.text = "\(presenter.numberOfAcceptedSignatures) of \(presenter.numberOfNeddedSignatures)"
    return headerView
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = presenter.sections[indexPath.section]
    let row = section.rows[indexPath.row]
    
    switch row {
    case .operation(let title):
      let cell: OperationTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
      cell.setOperationTitle(title)
      return cell
    case .operationDetail(let name, let value):
      let cell: OperationDetailsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
      
      cell.setData(title: name.capitalizingFirstLetter(), value: value)
      cell.selectionStyle = .none
      return cell
    case .additionalInformation(let name, let value):
      let cell: OperationDetailsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
      cell.setData(title: name, value: value)
      cell.selectionStyle = .none
      return cell
    case .signer(let signerViewData):
      let cell: SignerTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
      cell.setData(viewData: signerViewData)
      cell.selectionStyle = .none
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView,
                 didSelectRowAt indexPath: IndexPath) {
    guard let _ = tableView.cellForRow(at: indexPath) as? OperationTableViewCell else { return }
    tableView.deselectRow(at: indexPath, animated: true)
    presenter.operationWasSelected(by: indexPath.item)
  }
  
  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat {
    return presenter.sections[indexPath.section].type.rowHeight
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return presenter.sections[section].type.headerHeight
  }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
