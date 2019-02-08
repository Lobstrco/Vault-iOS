import UIKit
import PKHUD

class TransactionDetailsViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .transactions
  var presenter: TransactionDetailsPresenter!
  
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setStaticStrings()
    
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
  
  // MARK: - Public
  
  private func setStaticStrings() {
    navigationItem.title = L10n.navTitleTransactionDetails
  }
  
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
    let alert = UIAlertController(title: L10n.textDenyDialogTitle, message: L10n.textDenyDialogDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleDeny, style: .destructive, handler: { _ in
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
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
}
