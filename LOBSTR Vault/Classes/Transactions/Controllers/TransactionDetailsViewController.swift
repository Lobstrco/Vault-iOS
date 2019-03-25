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
    let alert = UIAlertController(title: L10n.textDenyDialogTitle, message: L10n.textConfirmDialogDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleYes, style: .destructive, handler: { _ in
      self.presenter.confirmOperationWasConfirmed()
    }))
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  func setDenyingAlert() {
    let alert = UIAlertController(title: L10n.textDenyDialogTitle, message: L10n.textDenyDialogDescription, preferredStyle: .alert)
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
    navigationItem.hidesBackButton = isEnable
    isEnable ? HUD.show(.labeledProgress(title: nil, subtitle: L10n.animationWaiting)) : HUD.hide()
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
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard presenter.numberOfOperation == 1 else {
      return presenter.numberOfOperation
    }
    
    return presenter.numberOfOperationDetails
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard presenter.numberOfOperation == 1 else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "OperationTableViewCell",
                                               for: indexPath) as! OperationTableViewCell
      presenter.configure(cell, forRow: indexPath.item)
      return cell
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "OperationDetailsTableViewCell",
                                             for: indexPath) as! OperationDetailsTableViewCell
    presenter.configure(cell, forRow: indexPath.item)
    cell.selectionStyle = .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard presenter.numberOfOperation != 1 else {
      return
    }
    
    tableView.deselectRow(at: indexPath, animated: true)
    presenter.operationWasSelected(by: indexPath.item)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
}
