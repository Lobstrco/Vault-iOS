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
  
  @IBOutlet var signersNumberStackView: UIStackView!
  @IBOutlet var signedAccountsNumberButton: UIButton!
  
  @IBOutlet var accountLabel: UILabel!
  
  @IBOutlet var idenctionView: IdenticonView!
  @IBOutlet var cardIconView: UIImageView!
    
  @IBOutlet var transactionNumberButton: UIButton!
  @IBOutlet var transactionListButton: UIButton!
  @IBOutlet var transactionsToSignLabel: UILabel!
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  @IBOutlet var refreshButton: UIButton!
  
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
      idenctionView.loadIdenticon(publicAddress: presenter.publicKey ?? "")
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
  
  func reloadData(signedAccountsNumber: Int) {
    topView.subviews.first?.isHidden = signedAccountsNumber == 0 ? true : false
    topViewHeightConstraint.constant = signedAccountsNumber == 0 ? 100 : 260
    signerViewHeightConstraint.isActive = signedAccountsNumber == 0 ? true : false
    emptyViewHeightConstraint.constant = signedAccountsNumber == 0 ? 300 : 0
    tableViewHeightConstraint.constant = signedAccountsNumber == 0 ? 0 : CGFloat(60 * signedAccountsNumber)
    tableView.reloadData()
  }
  
  func openNicknameDialog(by index: Int) {
    let nicknameDialogViewController = NicknameDialogViewController.createFromStoryboard()
    nicknameDialogViewController.delegate = self
    nicknameDialogViewController.index = index
    nicknameDialogViewController.nickName = self.presenter.signedAccounts[index].nickname
    self.navigationController?.present(nicknameDialogViewController, animated: false, completion: nil)
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
    if number > 9 {
      signersNumberStackView.spacing = 5
    }
    signedAccountsNumberButton.setTitle(number.description, for: .normal)
  }
  
  func setAccountLabel() {
    let title = UserDefaultsHelper.numberOfSignerAccounts > 1 ? "accounts" : "account"
    accountLabel.text = title
  }
  
  func rotateRefreshButton(isRotating: Bool) {
    if isRotating {
      DispatchQueue.main.async {
        self.refreshButton.layer.removeAllAnimations()
      }
    } else {
      let spinAnimation = CABasicAnimation()
      spinAnimation.fromValue = 0
      spinAnimation.toValue = Double.pi * 2
      spinAnimation.duration = 0.8
      spinAnimation.repeatCount = Float.infinity
      spinAnimation.isRemovedOnCompletion = false
      spinAnimation.fillMode = CAMediaTimingFillMode.forwards
      spinAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
      refreshButton.layer.add(spinAnimation, forKey: "transform.rotation.z")
    }
  }
  
  func actionSheetForSignersListWasPressed(with index: Int, isNicknameSet: Bool) {
    let moreMenu = UIAlertController(title: nil,
                                     message: nil,
                                     preferredStyle: .actionSheet)
    
    let copyAction = UIAlertAction(title: L10n.buttonTextCopy,
                                   style: .default) { _ in
      self.presenter.copySignerPublicKeyActionWasPressed(with: index)
    }
    
    let openExplorerAction = UIAlertAction(title: L10n.buttonTextOpenExplorer,
                                           style: .default) { _ in
      self.presenter.explorerSignerAccountActionWasPressed(with: index)
    }
    
    moreMenu.addAction(openExplorerAction)
    moreMenu.addAction(copyAction)
    
    if isNicknameSet {
      let changeAccountNicknameAction = UIAlertAction(title: L10n.buttonTextChangeAccountNickname,
                                                      style: .default) { _ in
        self.openNicknameDialog(by: index)
      }
      
      let clearAccountNicknameAction = UIAlertAction(title: L10n.buttonTextClearAccountNickname,
                                                     style: .default) { _ in
        self.presenter.clearAccountNicknameActionWasPressed(by: index)
      }
      clearAccountNicknameAction.setValue(UIColor.red, forKey: "titleTextColor")
      moreMenu.addAction(changeAccountNicknameAction)
      moreMenu.addAction(clearAccountNicknameAction)
    } else {
      let setAccountNicknameAction = UIAlertAction(title: L10n.buttonTextSetAccountNickname,
                                                   style: .default) { _ in
        self.openNicknameDialog(by: index)
      }
      moreMenu.addAction(setAccountNicknameAction)
    }
    
    let cancelAction = UIAlertAction(title: L10n.buttonTextCancel, style: .cancel)
        
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
    presenter.moreDetailsButtonWasPressed(with: indexPath.row)
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

// MARK: - NicknameDialogDelegate

extension HomeViewController: NicknameDialogDelegate {
  func submitNickname(with text: String, by index: Int?) {
    self.presenter.setAccountNicknameActionWasPressed(with: text, by: index)
  }
}
