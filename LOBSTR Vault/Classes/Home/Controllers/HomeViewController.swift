import Kingfisher
import PKHUD
import UIKit

class HomeViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .home
  
  @IBOutlet var tableView: UITableView!
  
  var presenter: HomePresenter!
  var isUpdatingTransactionNumber = true
}

// MARK: - Lifecycle

extension HomeViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter = HomePresenterImpl(view: self)
    presenter.homeViewDidLoad()
    
    setAppearance()
    setTableView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setStatusBar(backgroundColor: Asset.Colors.main.color)
    navigationController?.navigationBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.isHidden = false
  }
  
  @IBAction func refreshButtonAction(_ sender: UIButton) {
    presenter.refreshButtonWasPressed()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}

// MARK: - Private

private extension HomeViewController {
  func setTableView() {
    tableView.registerNib(TransactionsToSignTableViewCell.self)
    tableView.registerNib(VaultPublicKeyTableViewCell.self)
    tableView.registerNib(SignersTotalNumberTableViewCell.self)
    tableView.registerNib(SignerAccountTableViewCell.self)
    tableView.registerNib(SignersBottomTileTableViewCell.self)
    
    tableView.tableFooterView = UIView()
  }
  
  func setAppearance() {
    AppearanceHelper.set(navigationController)
  }
  
  func actionSheetForSignersListWasPressed(with index: Int) {
    let moreMenu = UIAlertController(title: nil,
                                     message: nil,
                                     preferredStyle: .actionSheet)
    
    let copyAction = UIAlertAction(title: "Copy Public Key",
                                   style: .default) { _ in
                                    self.presenter.copySignerPublicKeyActionWasPressed(with: index)
    }
    
    let openExplorerAction = UIAlertAction(title: "Open Explorer",
                                   style: .default) { _ in
                                    self.presenter.explorerSignerAccountActionWasPressed(with: index)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
    moreMenu.addAction(openExplorerAction)
    moreMenu.addAction(copyAction)
    moreMenu.addAction(cancelAction)
    
    if let popoverPresentationController = moreMenu.popoverPresentationController {
      popoverPresentationController.sourceView = self.view
      popoverPresentationController.sourceRect = CGRect(x: view.bounds.midX,
                                                        y: view.bounds.midY,
                                                        width: 0,
                                                        height: 0)
      popoverPresentationController.permittedArrowDirections = []
    }
    
    present(moreMenu, animated: true, completion: nil)
  }
}

// MARK: - HomeView

extension HomeViewController: HomeView {
  
  func reloadTableViewSections(_ sections: [Int]) {
    // Workaround to prevent jumpy updting of table view, if use
    // reloadData() method.
    DispatchQueue.main.async {
      UIView.performWithoutAnimation {
        self.tableView.reloadSections(IndexSet(sections), with: .none)      
      }
    }
  }
  
  func reloadSignerListRow(_ row: Int) {
    let indexPath = IndexPath(row: row, section: HomeSectionType.listOfSigners.index)
    tableView.reloadRows(at: [indexPath], with: .automatic)
  }
  
  func setProgressAnimationForTransactionNumber(isEnabled: Bool) {
    isUpdatingTransactionNumber = isEnabled
    
    reloadTableViewSections([HomeSectionType.transactionsToSign.index])
  }
  
  func setCopyHUD() {
    PKHUD.sharedHUD.contentView = PKHUDSuccessViewCustom(title: nil,
                                                         subtitle: L10n.animationCopy)
    PKHUD.sharedHUD.show()
    PKHUD.sharedHUD.hide(afterDelay: 1.0)
  }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return presenter.sections.count
  }
  
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return presenter.sections[section].rows.count
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = presenter.sections[indexPath.section]
    let row = section.rows[indexPath.row]
    
    switch row {
    case .numberOfTransactions(let transactionsNumber):
      let cell: TransactionsToSignTableViewCell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
      
      if isUpdatingTransactionNumber {
        cell.transactionNumberLabel.isHidden = true
        cell.activityIndicator.startAnimating()
      } else {
        cell.transactionNumberLabel.isHidden = false
        cell.activityIndicator.stopAnimating()
      }
      
      cell.transactionNumberLabel.text = transactionsNumber
      cell.delegate = self
      return cell
      
    case .publicKey(let publicKey):
      let cell: VaultPublicKeyTableViewCell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
      cell.delegate = self
      cell.publicKeyLabel.text = publicKey.getTruncatedPublicKey(numberOfCharacters: 14)
      cell.idenctionView.loadIdenticon(publicAddress: publicKey)
      
      return cell
    case .totalNumber(let number):
      let cell: SignersTotalNumberTableViewCell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
      cell.signerTotalNumberButton.setTitle("\(number)", for: .normal)
      if number == 1 {
        cell.accountLabel.text = "account"
      } else {
        cell.accountLabel.text = "accounts"
      }
      cell.delegate = self
      return cell
      
    case .signer(let signerAccount):
      let cell: SignerAccountTableViewCell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
      cell.set(signerAccount)
      cell.delegate = self
      // Do not show separator for the last cell.
      let signersSection = presenter.sections[HomeSectionType.listOfSigners.index]
      if indexPath.row == signersSection.rows.count - 1 {
        cell.separatorView.isHidden = true
      } else {
        cell.separatorView.isHidden = false
      }
      
      return cell
      
    case .bottom:
      let cell: SignersBottomTileTableViewCell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
      return cell
    }
  }
}

// MARK: - SignerAccountDelegate

extension HomeViewController: SignerAccountDelegate {
  func moreDetailsButtonWasPressed(in cell: SignerAccountTableViewCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    actionSheetForSignersListWasPressed(with: indexPath.row)
  }
  
  func longTapWasActivated(in cell: SignerAccountTableViewCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    presenter.copySignerPublicKeyActionWasPressed(with: indexPath.row)
  }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat {
    let section = presenter.sections[indexPath.section]
    let row = section.rows[indexPath.row]
    return row.height
  }
}

// MARK: - TransactionsToSignTableViewCellDelegate

extension HomeViewController: TransactionsToSignTableViewCellDelegate {
  func viewTransactionListDidPress() {
    tabBarController?.selectedIndex = 1
  }
}

// MARK: - VaultPublicKeyTableViewCellDelegate

extension HomeViewController: VaultPublicKeyTableViewCellDelegate {
  func copyButtonDidPress() {
    presenter.copyKeyButtonWasPressed()
  }
}

// MARK: - SignersTotalNumberTableViewCellDelegate

extension HomeViewController: SignersTotalNumberTableViewCellDelegate {
  func numberOfSignerButtonDidPress() {
    let signerDetailsTableViewController =
      SignerDetailsTableViewController.createFromStoryboard()
    
    navigationController?.pushViewController(signerDetailsTableViewController,
                                             animated: true)
  }
}
