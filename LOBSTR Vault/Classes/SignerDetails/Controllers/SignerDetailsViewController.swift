import PKHUD
import UIKit

protocol SignerDetailsView: class {
  func setAccountList(isEmpty: Bool)
  func setProgressAnimation()
  func copy(_ publicKey: String)
  func reloadRow(_ row: Int)
  func actionSheetForSignersListWasPressed(with index: Int, isNicknameSet: Bool)
}

class SignerDetailsViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .signerDetails
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var emptyStateView: UIView!
  @IBOutlet var emptyStateLabel: UILabel!
  
  var presenter: SignerDetailsPresenter!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setAppearance()
    presenter = SignerDetailsPresenterImpl(view: self)
    presenter.signerDetailsViewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    tabBarController?.tabBar.isHidden = false
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    navigationItem.title = L10n.navTitleSettingsSignedAccounts
  }
  
  private func setEmptyStateView() {
    emptyStateView.isHidden = false
    emptyStateLabel.text = L10n.textEmptyStateSignedAccounts
  }
  
  func removeEmptyStateView() {
    emptyStateView.isHidden = true
  }
  
  func openNicknameDialog(by index: Int) {
    let nicknameDialogViewController = NicknameDialogViewController.createFromStoryboard()
    nicknameDialogViewController.delegate = self
    nicknameDialogViewController.index = index
    nicknameDialogViewController.nickName = self.presenter.signedAccounts[index].nickname
    self.navigationController?.present(nicknameDialogViewController, animated: false, completion: nil)
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
    return 80
  }
  
}

// MARK: - SignerDetailsTableViewCellDelegate

extension SignerDetailsViewController: SignerDetailsTableViewCellDelegate {
  func moreDetailsButtonWasPressed(in cell: SignerDetailsTableViewCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    presenter.moreDetailsButtonWasPressed(with: indexPath.row)
  }
}

// MARK: - SignerDetailsView

extension SignerDetailsViewController: SignerDetailsView {
  func setAccountList(isEmpty: Bool) {
    tableView.reloadData()
    HUD.hide()
    
    if isEmpty {
      setEmptyStateView()
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
  
  func actionSheetForSignersListWasPressed(with index: Int, isNicknameSet: Bool) {
    let moreMenu = UIAlertController(title: nil,
                                     message: nil,
                                     preferredStyle: .actionSheet)
    
    let copyAction = UIAlertAction(title: L10n.buttonTextCopy,
                                   style: .default) { _ in
      self.presenter.copyAlertActionWasPressed(for: index)
    }
    
    let openExplorerAction = UIAlertAction(title: L10n.buttonTextOpenExplorer,
                                           style: .default) { _ in
      self.presenter.openExplorerActionWasPressed(for: index)
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

// MARK: - NicknameDialogDelegate

extension SignerDetailsViewController: NicknameDialogDelegate {
  func submitNickname(with text: String, by index: Int?) {
    self.presenter.setAccountNicknameActionWasPressed(with: text, by: index)
  }
}
