import PKHUD
import stellarsdk
import UIKit

class OperationViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .transactions
  
  var presenter: OperationPresenter!
  
  @IBOutlet var tableView: UITableView!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerNibForHeaderFooter(SignersHeaderView.self)
    tableView.registerNibForHeaderFooter(SignersFooterView.self)
    tableView.register(UINib(nibName: "OperationDetailsTableViewCell", bundle: nil),
                       forCellReuseIdentifier: "OperationDetailsTableViewCell")
    tableView.register(UINib(nibName: "SignerTableViewCell", bundle: nil),
                       forCellReuseIdentifier: "SignerTableViewCell")
        
    presenter.operationViewDidLoad()
    configureTableView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    tabBarController?.tabBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    tabBarController?.tabBar.isHidden = false
  }
  
  // MARK: - Public
  
  func configureTableView() {
    tableView.tableFooterView = UIView()
    tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
    tableView.sectionFooterHeight = 0.0
    tableView.sectionHeaderHeight = 0.0
    
    tableView.delegate = self
    tableView.dataSource = self
  }
}

// MARK: - OperationDetailsView

extension OperationViewController: OperationDetailsView {
  func setListOfOperationDetails() {
    tableView.reloadData()
  }
  
  func setTitle(_ title: String) {
    navigationItem.title = title
  }
  
  func showActionSheet(_ value: Any?, _ type: ActionSheetType) {
    let moreMenu = UIAlertController(title: nil,
                                     message: nil,
                                     preferredStyle: .actionSheet)
    
    switch type {
    case .assetCode:
      if let asset = value as? stellarsdk.Asset {
        let openExplorerAction = UIAlertAction(title: L10n.buttonTextOpenExplorer,
                                               style: .default) { _ in
          self.presenter.explorerAsset(asset)
        }
        
        moreMenu.addAction(openExplorerAction)
      }
    case .publicKey(let isNicknameSet, let type, let isVaultSigner):
      if let key = value as? String {
        let copyAction = UIAlertAction(title: L10n.buttonTextCopy,
                                       style: .default) { _ in
          self.presenter.copyPublicKey(key)
        }
        
        let openExplorerAction = UIAlertAction(title: L10n.buttonTextOpenExplorer,
                                               style: .default) { _ in
          self.presenter.explorerPublicKey(key)
        }
        
        if !isVaultSigner {
          moreMenu.addAction(openExplorerAction)
        }
        moreMenu.addAction(copyAction)
        
        if isNicknameSet {
          let changeAccountNicknameAction = UIAlertAction(title: L10n.buttonTextChangeAccountNickname,
                                                          style: .default) { _ in
            self.openNicknameDialog(for: key, nicknameDialogType: type)
          }
          
          let clearAccountNicknameAction = UIAlertAction(title: L10n.buttonTextClearAccountNickname,
                                                         style: .default) { _ in
            self.presenter.clearNicknameActionWasPressed(key, nicknameDialogType: type)
          }
          clearAccountNicknameAction.setValue(UIColor.red, forKey: "titleTextColor")
          moreMenu.addAction(changeAccountNicknameAction)
          moreMenu.addAction(clearAccountNicknameAction)
        } else {
          let setAccountNicknameAction = UIAlertAction(title: L10n.buttonTextSetAccountNickname,
                                                       style: .default) { _ in
            self.openNicknameDialog(for: key, nicknameDialogType: type)
          }
          moreMenu.addAction(setAccountNicknameAction)
        }
      }
    case .nativeAssetCode:
      let openExplorerAction = UIAlertAction(title: L10n.buttonTextOpenExplorer,
                                             style: .default) { _ in
        self.presenter.explorerNativeAsset()
      }
  
      moreMenu.addAction(openExplorerAction)
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
  
  func copy(_ text: String) {
    let pasteboard = UIPasteboard.general
    pasteboard.string = text
    HUD.flash(.labeledSuccess(title: nil,
                              subtitle: L10n.animationCopy), delay: 1.0)
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
  
  func setProgressAnimation(isEnabled: Bool) {
    DispatchQueue.main.async {
      self.navigationItem.hidesBackButton = isEnabled
      if let topVC = UIApplication.getTopViewController() {
        if !(topVC is PinEnterViewController) {
          isEnabled ? HUD.show(.labeledProgress(title: nil,
                                                subtitle: L10n.animationWaiting)) : HUD.hide()
        }
      }
    }
  }
}

// MARK: - UITableView

extension OperationViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return presenter.sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.sections[section].rows.count
  }
    
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = presenter.sections[indexPath.section]
    let row = section.rows[indexPath.row]
    
    switch row {
    case .additionalInformation((let name, let value, let nickname, let isPublicKey)):
      let cell: OperationDetailsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
      if name.contains("Memo") {
        cell.type = .memo
      }
      if isPublicKey {
        cell.type = .publicKey
      }
      if isPublicKey, !nickname.isEmpty {
        let value = nickname + " (\(value.prefix(4))...\(value.suffix(4)))"
        cell.setData(title: name, value: value)
      } else {
        cell.setData(title: name, value: value)
      }
      cell.selectionStyle = .none
      return cell
    case .operationDetail((let name, let value, let nickname, let isPublicKey, let isAssetCode)):
      let cell: OperationDetailsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
      if name.contains("Memo") {
        cell.type = .memo
      }
      if name.contains("Flags") {
        cell.type = .flags
      }
      if isPublicKey {
        cell.type = .publicKey
      }
      if name.contains(L10n.textClaimBetween) {
        cell.type = .claimBetween
      }
      if isAssetCode {
        cell.type = .assetCode
      }
      if isPublicKey, !nickname.isEmpty {
        let value = nickname + " (\(value.prefix(4))...\(value.suffix(4)))"
        cell.setData(title: name, value: value)
      } else {
        cell.setData(title: name, value: value)
      }
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
                 heightForRowAt indexPath: IndexPath) -> CGFloat
  {
    switch presenter.sections[indexPath.section].rows[indexPath.row] {
    case .operationDetail((let name, let value, _, _, _)):
      if name.contains("Flags") {
        let separateCount = value.components(separatedBy: "\n").count - 1
        if separateCount > 1 {
          return 70
        } else {
          return presenter.sections[indexPath.section].type.rowHeight
        }
      } else {
        return presenter.sections[indexPath.section].type.rowHeight
      }
    default:
      return presenter.sections[indexPath.section].type.rowHeight
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch presenter.sections[section].type {
    case .operationDetails:
      if presenter.sections[section].rows.count != 0 {
        return presenter.sections[section].type.headerHeight
      } else {
        return 0
      }
    default:
      return presenter.sections[section].type.headerHeight
    }
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    switch presenter.sections[section].type {
    case .signers:
      let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SignersHeaderView.reuseIdentifier) as! SignersHeaderView
      headerView.titleLabel.text = L10n.textSignersHeaderTitle
      headerView.numberOfAcceptedSignaturesLabel.isHidden = !presenter.isNeedToShowSignaturesNumber
      headerView.numberOfAcceptedSignaturesLabel.text = "\(presenter.numberOfAcceptedSignatures) of \(presenter.numberOfNeededSignatures)"
      return headerView
    case .operationDetails:
      let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SignersHeaderView.reuseIdentifier) as! SignersHeaderView
      headerView.titleLabel.text = L10n.textOperationDetailsHeaderTitle
      headerView.numberOfAcceptedSignaturesLabel.isHidden = true
      return headerView
    default:
      return nil
    }
  }
  
  func tableView(_ tableView: UITableView,
                 didSelectRowAt indexPath: IndexPath)
  {
    if let cell = tableView.cellForRow(at: indexPath) as? OperationDetailsTableViewCell, cell.type == .publicKey {
      tableView.deselectRow(at: indexPath, animated: true)
      presenter.publicKeyWasSelected(key: cell.valueLabel.text)
    } else if let cell = tableView.cellForRow(at: indexPath) as? OperationDetailsTableViewCell, cell.type == .assetCode {
      presenter.assetCodeWasSelected(code: cell.valueLabel.text)
    } else if let cell = tableView.cellForRow(at: indexPath) as? SignerTableViewCell {
      tableView.deselectRow(at: indexPath, animated: true)
      presenter.signerWasSelected(cell.viewData)
    } else { return }
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    guard presenter.isNeedToShowHelpfulMessage else { return 0 }
    switch presenter.sections[section].type {
    case .signers:
      return SignersFooterView.height
    default:
      return 0
    }
  }
    
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    guard presenter.isNeedToShowHelpfulMessage else { return nil }
    switch presenter.sections[section].type {
    case .signers:
      let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SignersFooterView.reuseIdentifier) as! SignersFooterView
      let text = presenter.numberOfNeededSignatures > 1 ? L10n.textSignaturesRequiredMessage("\(presenter.numberOfNeededSignatures)") : L10n.textSignatureRequiredMessage("\(presenter.numberOfNeededSignatures)")
      footerView.messageLabel.text = text
      return footerView
    default:
      return nil
    }
  }
}

// MARK: - Private

extension OperationViewController {
  private func openNicknameDialog(for publicKey: String, nicknameDialogType: NicknameDialogType) {
    var nickname: String?
    if let index = presenter.storageAccounts.firstIndex(where: { $0.address == publicKey }) {
      nickname = presenter.storageAccounts[index].nickname
    }
    let nicknameDialogViewController = NicknameDialogViewController.createFromStoryboard()
    nicknameDialogViewController.delegate = self
    nicknameDialogViewController.publicKey = publicKey
    nicknameDialogViewController.nickname = nickname
    nicknameDialogViewController.type = nicknameDialogType
    navigationController?.present(nicknameDialogViewController, animated: false, completion: nil)
  }
}

// MARK: - NicknameDialogDelegate

extension OperationViewController: NicknameDialogDelegate {
  func displayNoInternetConnectionAlert() {
    showNoInternetConnectionAlert()
  }
  
  func submitNickname(with text: String,
                      for publicKey: String?,
                      nicknameDialogType: NicknameDialogType?)
  {
    presenter.setNicknameActionWasPressed(with: text,
                                          for: publicKey,
                                          nicknameDialogType: nicknameDialogType)
  }
}
