import UIKit

protocol PublicKeyListView: AnyObject {
  func setAccounts(_ accounts: [SignedAccount])
  func dismiss()
}

protocol PublicKeyListDelegate: AnyObject {
  func publicKeyWasSelected()
}

class PublicKeyListViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .home
  
  @IBOutlet var headerView: UIView! {
    didSet {
      headerView.layer.cornerRadius = 10.0
    }
  }
  @IBOutlet var tableView: UITableView!
  @IBOutlet var addNewAccountView: UIView!
  @IBOutlet var addNewAccountViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet var tableViewBottomConstraint: NSLayoutConstraint!
  
  
  var presenter: PublicKeyListPresenter!
  
  weak var delegate: PublicKeyListDelegate?
  
  private var accounts: [SignedAccount] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    tableView.delegate = self
    presenter = PublicKeyListPresenterImpl(view: self, publicKeyListDelegate: delegate)
    presenter.homeViewDidLoad()
  }
  
  
  @IBAction func addNewAccountButtonAction(_ sender: Any) {
    presenter.addNewAccount()
  }
}

extension PublicKeyListViewController: PublicKeyListView {
  func setAccounts(_ accounts: [SignedAccount]) {
    self.accounts = accounts
    if accounts.count == MnemonicHelper.additionalAccountsCountLimit + 1 {
      hideAddNewAccountView()
    }
    markAccountAsSelected()
  }
  
  func dismiss() {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - UITableViewDelegate

extension PublicKeyListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat
  {
    return MultiaccountPublicKeyTableViewCell.height
  }
  
  func tableView(_ tableView: UITableView,
                 didSelectRowAt indexPath: IndexPath) {
    presenter.accountWasSelected(by: indexPath.row)
    dismiss()
  }
}


// MARK: - UITableViewDataSource

extension PublicKeyListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int
  {
    return accounts.count
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell: MultiaccountPublicKeyTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
    cell.idenctionView.layer.borderWidth = 2.0
    cell.selectionStyle = .none
    let index = indexPath.row
    cell.set(accounts[index], index: index)
    return cell
  }
}

private extension PublicKeyListViewController {
  func markAccountAsSelected() {
    let path = IndexPath(row: UserDefaultsHelper.activePublicKeyIndex, section: 0)
    self.tableView.selectRow(at: path, animated: true, scrollPosition: .bottom)
  }
  
  func hideAddNewAccountView () {
    addNewAccountView.isHidden = true
    addNewAccountViewHeightConstraint.constant = 0.0
    tableViewBottomConstraint.isActive = false
    tableView.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor, constant: 0.0).isActive = true
  }
}
