import PKHUD
import UIKit

protocol SignerDetailsView: AnyObject {
  func setAccountList(isEmpty: Bool)
  func setProgressAnimation()
  func copy(_ publicKey: String)
  func reloadRow(_ row: Int)
  func actionSheetForSignersListWasPressed(with publicKey: String, isNicknameSet: Bool)
  func showICloudSyncAdviceAlert()
  func showNoInternetConnectionAlert()
  func showICloudSyncScreen()
}

enum SignerDetailsScreenType {
  case protectedAccounts
  case manageNicknames
}

class SignerDetailsViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .signerDetails
  
  var screenType: SignerDetailsScreenType = .protectedAccounts

  @IBOutlet var tableView: UITableView!
  @IBOutlet var emptyStateView: UIView!
  @IBOutlet var emptyStateLabel: UILabel!
  @IBOutlet var addNewNicknameButton: UIButton! {
    didSet {
      addNewNicknameButton.layer.cornerRadius = 28.0
    }
  }
  
  var presenter: SignerDetailsPresenter!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setAppearance()
    presenter = SignerDetailsPresenterImpl(view: self, screenType: screenType)
    presenter.signerDetailsViewDidLoad()
    setTableView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = true
    navigationController?.setNavigationBarAppearance(backgroundColor: Asset.Colors.background.color)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    tabBarController?.tabBar.isHidden = false
    navigationController?.setNavigationBarAppearanceWithoutSeparatorForStandardAppearance()
  }
  
  // MARK: - Action
  
  @IBAction func addNewNicknameButtonAction(_ sender: UIButton) {
    presenter.addNicknameButtonWasPressed()
  }
  
  // MARK: - Private
  
  private func setTableView() {
    tableView.delaysContentTouches = false
    for case let subview as UIScrollView in tableView.subviews {
      subview.delaysContentTouches = false
    }
    tableView.delegate = self
    tableView.dataSource = self
    let footerView = screenType == .protectedAccounts ? UIView() : UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 90))
    tableView.tableFooterView = footerView
    if #available(iOS 15.0, *)
    {
      tableView.tableHeaderView = UIView()
    }
  }
    
  private func setAppearance() {
    switch screenType {
    case .protectedAccounts:
      navigationItem.title = L10n.navTitleSettingsSignedAccounts
      addNewNicknameButton.isHidden = true
    case .manageNicknames:
      navigationItem.title = L10n.navTitleSettingsManageNicknames
      addNewNicknameButton.isHidden = false
    }
  }
  
  private func setEmptyStateView() {
    emptyStateView.isHidden = false
    let text = screenType == .protectedAccounts ? L10n.textEmptyStateSignedAccounts : L10n.textEmptyStateManageNicknames
    emptyStateLabel.text = text
  }
  
  func removeEmptyStateView() {
    emptyStateView.isHidden = true
  }
  
  
  func openNicknameDialog(for publicKey: String) {
    let nicknameDialogType: NicknameDialogType = screenType == .protectedAccounts ? .protectedAccount : .otherAccount
    let accounts = screenType == .protectedAccounts ? presenter.signedAccounts : presenter.sortedNicknames
    
    if let index = accounts.firstIndex(where: { $0.address == publicKey }) {
      let nicknameDialogViewController = NicknameDialogViewController.createFromStoryboard()
      nicknameDialogViewController.delegate = self
      nicknameDialogViewController.publicKey = publicKey
      nicknameDialogViewController.nickname = accounts[index].nickname
      nicknameDialogViewController.type = nicknameDialogType
      navigationController?.present(nicknameDialogViewController, animated: false, completion: nil)
    }
  }
}

// MARK: - UITableView

extension SignerDetailsViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.countOfAccounts
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: SignerDetailsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
    presenter.configure(cell, forRow: indexPath.item)
    cell.delegate = self
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 64
  }
}

// MARK: - SignerDetailsTableViewCellDelegate

extension SignerDetailsViewController: SignerDetailsTableViewCellDelegate {
  func moreDetailsButtonWasPressed(in cell: SignerDetailsTableViewCell) {
    guard let publicKey = cell.publicKey else { return }
    presenter.moreDetailsButtonWasPressed(for: publicKey)
  }
}

// MARK: - SignerDetailsView

extension SignerDetailsViewController: SignerDetailsView {
  func setAccountList(isEmpty: Bool) {
    tableView.reloadData()
    HUD.hide()
    
    if isEmpty {
      setEmptyStateView()
    } else {
      removeEmptyStateView()
    }
  }
  
  func setProgressAnimation() {
    DispatchQueue.main.async {
      HUD.show(.labeledProgress(title: nil, subtitle: L10n.animationWaiting))
    }
  }
  
  func copy(_ publicKey: String) {
    let pasteboard = UIPasteboard.general
    pasteboard.string = publicKey
    HUD.flash(.labeledSuccess(title: nil,
                              subtitle: L10n.animationCopy), delay: 1.0)
  }
  
  func reloadRow(_ row: Int) {
    let indexPath = IndexPath(row: row, section: 0)
    tableView.reloadRows(at: [indexPath], with: .automatic)
  }
    
  func actionSheetForSignersListWasPressed(with publicKey: String,
                                           isNicknameSet: Bool) {
    
    let moreMenu = UIAlertController(title: nil,
                                     message: nil,
                                     preferredStyle: .actionSheet)
    
    
    let copyAction = UIAlertAction(title: L10n.buttonTextCopy,
                                   style: .default) { _ in
      self.presenter.copyAlertActionWasPressed(publicKey)
    }
    
    let openExplorerAction = UIAlertAction(title: L10n.buttonTextOpenExplorer,
                                           style: .default) { _ in
      self.presenter.openExplorerActionWasPressed(publicKey)
    }
    
    switch screenType {
    case .protectedAccounts:
      moreMenu.addAction(openExplorerAction)
      moreMenu.addAction(copyAction)
    case .manageNicknames:
      
      let accountsPublicKeys =
        AccountsStorageHelper.getMainAccountsFromCache()
        .compactMap { $0.address}
      
      
      if !accountsPublicKeys.contains(publicKey) {
        moreMenu.addAction(openExplorerAction)
      }
      
      moreMenu.addAction(copyAction)
    }
    

    if isNicknameSet {
      let changeAccountNicknameAction = UIAlertAction(title: L10n.buttonTextChangeAccountNickname,
                                                   style: .default) { _ in
        self.openNicknameDialog(for: publicKey)
      }
      
      let clearAccountNicknameAction = UIAlertAction(title: L10n.buttonTextClearAccountNickname,
                                                   style: .default) { _ in
        self.presenter.clearNicknameActionWasPressed(publicKey)
      }
      clearAccountNicknameAction.setValue(UIColor.red, forKey: "titleTextColor")
      
      moreMenu.addAction(changeAccountNicknameAction)
      moreMenu.addAction(clearAccountNicknameAction)
      
    } else {
      let setAccountNicknameAction = UIAlertAction(title: L10n.buttonTextSetAccountNickname,
                                                   style: .default) { _ in
        self.openNicknameDialog(for: publicKey)
      }
      moreMenu.addAction(setAccountNicknameAction)
    }
    
    let cancelAction = UIAlertAction(title: L10n.buttonTextCancel, style: .cancel)
        
    moreMenu.addAction(cancelAction)
    
    if let popoverPresentationController = moreMenu.popoverPresentationController {
      popoverPresentationController.sourceView = view
      popoverPresentationController.sourceRect = CGRect(x: view.bounds.midX,
                                                        y: view.bounds.midY,
                                                        width: 0,
                                                        height: 0)
      popoverPresentationController.permittedArrowDirections = []
    }
    
    present(moreMenu, animated: true, completion: nil)
  }
  
  func showICloudSyncAdviceAlert() {
    let alert = UIAlertController(title: L10n.textICloudSyncAdviceAlertTitle,
                                  message: L10n.textICloudSyncAdviceAlertDescription, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleProceed, style: .default, handler: { _ in
      self.presenter.proceedICloudSyncActionWasPressed()
    }))
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel))
    
    present(alert, animated: true, completion: nil)
  }
  
  func showNoInternetConnectionAlert() {
    let alert = UIAlertController(title: L10n.textICloudSyncNoInternetConnectionAlertTitle, message: L10n.textICloudSyncNoInternetConnectionAlertDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleOk, style: .cancel))

    present(alert, animated: true, completion: nil)
  }
  
  func showICloudSyncScreen() {
    let transactionConfirmationViewController = SettingsSelectionViewController.createFromStoryboard()
    transactionConfirmationViewController.screenType = .iCloudSync
    navigationController?.pushViewController(transactionConfirmationViewController, animated: true)
  }
}

// MARK: - NicknameDialogDelegate

extension SignerDetailsViewController: NicknameDialogDelegate {
  func displayNoInternetConnectionAlert() {
    showNoInternetConnectionAlert()
  }
  
  func submitNickname(with text: String, for publicKey: String?, nicknameDialogType: NicknameDialogType?) {
    switch nicknameDialogType {
    case .protectedAccount, .otherAccount:
      presenter.setNicknameActionWasPressed(with: text, for: publicKey)
    default:
      break
    }
  }
}
