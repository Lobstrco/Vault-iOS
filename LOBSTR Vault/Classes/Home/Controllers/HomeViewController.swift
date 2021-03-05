import Kingfisher
import PKHUD
import UIKit

class HomeViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .home
  
  @IBOutlet var scrollView: UIScrollView! {
    didSet {
      scrollView.delaysContentTouches = false
    }
  }
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var topView: UIView!
  @IBOutlet var publicKeyView: UIView!
  @IBOutlet var signersView: UIView!
  @IBOutlet var emptyView: UIView!
  
  @IBOutlet var topViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet var emptyViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet var signerViewHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet var multisigInfoButton: UIButton!
  @IBOutlet var multisigInfoEmptyStateButton: UIButton!
    
  @IBOutlet var publicKeyLabel: UILabel!
  @IBOutlet var titleOfPublicKeyLabel: UILabel!
  @IBOutlet var copyKeyButton: UIButton!
  
  @IBOutlet var signedAccountsNumberButton: UIButton!
  
  @IBOutlet var accountLabel: UILabel!
  
  @IBOutlet var idenctionView: IdenticonView!
  @IBOutlet var cardIconView: UIImageView!
    
  @IBOutlet var transactionNumberButton: UIButton!
  @IBOutlet var transactionListButton: UIButton!
  @IBOutlet var transactionsToSignLabel: UILabel!
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  
  var presenter: HomePresenter!
}

// MARK: - Lifecycle

extension HomeViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    tryToShowPinEnterViewController()
    publicKeyView.subviews.first?.layer.borderWidth = 1
    publicKeyView.subviews.first?.layer.cornerRadius = 5
    publicKeyView.subviews.first?.layer.borderColor = UIColor.clear.cgColor
    publicKeyView.subviews.first?.layer.masksToBounds = true
    
    publicKeyView.layer.shadowOpacity = 0.2
    publicKeyView.layer.shadowOffset = CGSize(width: 0, height: 1)
    publicKeyView.layer.shadowRadius = 4
    publicKeyView.layer.shadowColor = UIColor.black.cgColor
    publicKeyView.layer.masksToBounds = false
    
    signersView.subviews.first?.layer.borderWidth = 1
    signersView.subviews.first?.layer.cornerRadius = 5
    signersView.subviews.first?.layer.borderColor = UIColor.clear.cgColor
    signersView.subviews.first?.layer.masksToBounds = true
    
    signersView.layer.shadowOpacity = 0.2
    signersView.layer.shadowOffset = CGSize(width: 0, height: 1)
    signersView.layer.shadowRadius = 4
    signersView.layer.shadowColor = UIColor.black.cgColor
    signersView.layer.masksToBounds = false
    
    emptyView.subviews.first?.layer.borderWidth = 1
    emptyView.subviews.first?.layer.cornerRadius = 5
    emptyView.subviews.first?.layer.borderColor = UIColor.clear.cgColor
    emptyView.subviews.first?.layer.masksToBounds = true
    
    emptyView.layer.shadowOpacity = 0.2
    emptyView.layer.shadowOffset = CGSize(width: 0, height: 1)
    emptyView.layer.shadowRadius = 4
    emptyView.layer.shadowColor = UIColor.black.cgColor
    emptyView.layer.masksToBounds = false
    
    AppearanceHelper.set(multisigInfoButton, with: "Add Account")
    multisigInfoButton.layer.borderColor = Asset.Colors.main.color.cgColor
    multisigInfoButton.layer.borderWidth = 1
    
    AppearanceHelper.set(multisigInfoEmptyStateButton, with: "Add Account")
    multisigInfoEmptyStateButton.layer.borderColor = Asset.Colors.main.color.cgColor
    multisigInfoEmptyStateButton.layer.borderWidth = 1
    
    titleOfPublicKeyLabel.text = L10n.textVaultPublicKey
    AppearanceHelper.set(copyKeyButton, with: L10n.buttonTitleCopyKey)
    
    AppearanceHelper.set(transactionListButton,
                         with: L10n.buttonTitleViewTransactionsList)
    transactionsToSignLabel.text = L10n.textTransactionsToSign
    
    presenter = HomePresenterImpl(view: self)
    presenter.homeViewDidLoad()
    
    setTableView()
    setIconCardOrIdenticon()
  }
  
  @IBAction func copyKeyButtonAction(_ sender: UIButton) {
    presenter.copyKeyButtonWasPressed()
  }
  
  @IBAction func tranactionListButtonAction(_ sender: UIButton) {
    tabBarController?.selectedIndex = 1
  }
  
  @IBAction func signedAccountsButtonAction(_ sender: UIButton) {
    let signerDetailsViewController = SignerDetailsViewController.createFromStoryboard()
    navigationController?.pushViewController(signerDetailsViewController,
                                             animated: true)
  }
  
  @IBAction func refreshButtonAction(_ sender: UIButton) {
    presenter.refreshButtonWasPressed()
  }
  
  @IBAction func addAccountButtonAction(_ sender: UIButton) {
    let multisigViewController = MultisigInfoViewController.createFromStoryboard()
    multisigViewController.publicKey = presenter.publicKey ?? "none"
    navigationController?.present(multisigViewController, animated: true, completion: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presenter.homeViewDidAppear()
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
}

// MARK: - Private

private extension HomeViewController {
  func tryToShowPinEnterViewController() {
    if UserDefaultsHelper.isAfterLogin {
      UserDefaultsHelper.isAfterLogin = false
    } else {
      PinHelper.tryToShowPinEnterViewController()
    }
  }
  
  func setIconCardOrIdenticon() {
    switch UserDefaultsHelper.accountStatus {
    case .createdByDefault:
      idenctionView.loadIdenticon(publicAddress: presenter.publicKey!)
      idenctionView.isHidden = false
      cardIconView.isHidden = true
    case .createdWithTangem:
      cardIconView.isHidden = false
      idenctionView.isHidden = true
    default: return
    }
  }
  
  func setTableView() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorColor = .clear
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
  
  func reloadData(signedAccountsNumber: Int) {
    topView.subviews.first?.isHidden = signedAccountsNumber == 0 ? true : false
    topViewHeightConstraint.constant = signedAccountsNumber == 0 ? 100 : 260
    signerViewHeightConstraint.isActive = signedAccountsNumber == 0 ? true : false
    emptyViewHeightConstraint.constant = signedAccountsNumber == 0 ? 300 : 0
    tableViewHeightConstraint.constant = signedAccountsNumber == 0 ? 0 : CGFloat(60 * signedAccountsNumber)
    tableView.reloadData()
  }
}

// MARK: - HomeView

extension HomeViewController: HomeView {
  func setProgressAnimationForTransactionNumber() {
    DispatchQueue.main.async {
      self.transactionNumberButton.setTitle("", for: .normal)
      self.activityIndicator.startAnimating()
    }
  }
  
  func setCopyHUD() {
    PKHUD.sharedHUD.contentView = PKHUDSuccessViewCustom(title: nil,
                                                         subtitle: L10n.animationCopy)
    PKHUD.sharedHUD.show()
    PKHUD.sharedHUD.hide(afterDelay: 1.0)
  }
  
  func setPublicKey(_ publicKey: String) {
    publicKeyLabel.text = publicKey
  }
  
  func setSignedAccountsList(_ signedAccounts: [SignedAccount]) {
    reloadData(signedAccountsNumber: signedAccounts.count)
  }
  
  func setTransactionNumber(_ transactionNumber: String) {
    DispatchQueue.main.async {
      self.transactionNumberButton.setTitle(transactionNumber, for: .normal)
      self.activityIndicator.stopAnimating()
    }
  }
  
  func setNumberOfSignedAccount(_ number: Int) {
    signedAccountsNumberButton.setTitle(number.description, for: .normal)
  }
  
  func setAccountLabel() {
    let title = UserDefaultsHelper.numberOfSignerAccounts > 1 ? "accounts" : "account"
    accountLabel.text = title
  }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int
  {
    return presenter.signedAccounts.count
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell: SignerAccountTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
    cell.set(presenter.signedAccounts[indexPath.row])
    cell.delegate = self
    
    return cell
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
                 heightForRowAt indexPath: IndexPath) -> CGFloat
  {
    return 60
  }
}

// MARK: - VaultPublicKeyTableViewCellDelegate

extension HomeViewController: VaultPublicKeyTableViewCellDelegate {
  func copyButtonDidPress() {
    presenter.copyKeyButtonWasPressed()
  }
}
