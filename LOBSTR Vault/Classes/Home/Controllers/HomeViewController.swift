import Kingfisher
import PKHUD
import UIKit

class HomeViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .home
  
  @IBOutlet var tableView: UITableView!
  
  var presenter: HomePresenter!
  
  var isUpdatingTransactionNumber = true
  
  var sections: [HomeSection] = []
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    presenter.homeViewDidAppear()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}

// MARK: - Private

extension HomeViewController {
  private func setTableView() {
    tableView.registerNib(TransactionsToSignTableViewCell.self)
    tableView.registerNib(VaultPublicKeyTableViewCell.self)
    tableView.registerNib(SignersTotalNumberTableViewCell.self)
    tableView.registerNib(SignerAccountTableViewCell.self)
    tableView.registerNib(SignersBottomTileTableViewCell.self)
    
    tableView.tableFooterView = UIView()
  }
  
  private func setAppearance() {
    AppearanceHelper.set(navigationController)
  }
  
  private func reloadTableViewSections(_ sections: [Int]) {
    // Workaround to prevent jumpy updting of table view, if use
    // reloadData() method.
    UIView.performWithoutAnimation {
      let location = tableView.contentOffset
      tableView.reloadSections(IndexSet(sections), with: .none)
      tableView.contentOffset = location
    }
  }
}

// MARK: - HomeView

extension HomeViewController: HomeView {
  func setSections(_ sections: [HomeSection]) {
    self.sections = sections
    tableView.reloadData()
  }
  
  func setTransactionNumber(_ number: String) {
    let numberOfTransactionsSection = HomeSection(type: .transactionsToSign,
                                                  rows: [.numberOfTransactions(number)])
    sections[HomeSectionType.transactionsToSign.index] = numberOfTransactionsSection
    
    reloadTableViewSections([HomeSectionType.transactionsToSign.index])
  }
  
  func setPublicKey(_ publicKey: String) {
    let publicKeySection = HomeSection(type: .vaultPublicKey,
                                       rows: [.publicKey(publicKey)])
    
    sections[HomeSectionType.vaultPublicKey.index] = publicKeySection
    reloadTableViewSections([HomeSectionType.vaultPublicKey.index])
  }
  
  func setSignerDetails(_ signedAccounts: [SignedAccount]) {
    let numberOfSignersSection = HomeSection(type: .signersTotalNumber,
                                             rows: [.totalNumber(signedAccounts.count)])
    let signersSection = HomeSection(type: .listOfSigners,
                                     rows: signedAccounts.map { .signer($0) })
    
    sections[HomeSectionType.signersTotalNumber.index] = numberOfSignersSection
    sections[HomeSectionType.listOfSigners.index] = signersSection
    
    reloadTableViewSections([HomeSectionType.signersTotalNumber.index,
                             HomeSectionType.listOfSigners.index])
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
    return sections.count
  }
  
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return sections[section].rows.count
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = sections[indexPath.section]
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
      cell.publicKeyLabel.text = publicKey
      cell.idenctionView.loadIdenticon(publicAddress: publicKey)
      
      return cell
    case .totalNumber(let number):
      let cell: SignersTotalNumberTableViewCell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
      cell.signerTotalNumberButton.setTitle("\(number)", for: .normal)
      if number > 1 {
        cell.accountLabel.text = "accounts"
      } else {
        cell.accountLabel.text = "account"
      }
      cell.delegate = self
      return cell
      
    case .signer(let signerAccount):
      let cell: SignerAccountTableViewCell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
      cell.signerPublicAddressLabel.text = signerAccount.address
      
      if let address = signerAccount.address {
        cell.identiconView.loadIdenticon(publicAddress: address)
      }
      
      // Do not show separator for the last cell.
      let signersSection = sections[HomeSectionType.listOfSigners.index]
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

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat {
    let section = sections[indexPath.section]
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
