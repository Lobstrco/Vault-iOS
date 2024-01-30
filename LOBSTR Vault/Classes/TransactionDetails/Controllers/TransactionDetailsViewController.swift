import PKHUD
import stellarsdk
import UIKit

class TransactionDetailsViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .transactions
  var presenter: TransactionDetailsPresenter!
  var isAfterPushNotification: Bool = false
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var confirmButton: UIButton!
  @IBOutlet var denyButton: UIButton!
  @IBOutlet var expiredErrorLabel: UILabel!
  @IBOutlet var errorLabelHeightConstraint: NSLayoutConstraint!
  @IBOutlet var buttonsStackView: UIStackView!
  
  @IBOutlet var buttonsStackViewHeightConstraint: NSLayoutConstraint! {
    didSet {
      buttonsStackView.isHidden = true
      buttonsStackViewHeightConstraint.constant = 0.0
    }
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setStaticStrings()
    setAppearance()
    setupNavigationBar()
    
    presenter.transactionDetailsViewDidLoad()
    configureTableView()
    denyButton.layer.borderWidth = 1
    denyButton.layer.borderColor = Asset.Colors.red.color.cgColor
    denyButton.layer.cornerRadius = 4
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    tabBarController?.tabBar.isHidden = true
    navigationController?.setNavigationBarAppearance(backgroundColor: Asset.Colors.background.color)
    setAppearanceAfterPushNotification()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    tabBarController?.tabBar.isHidden = false
    navigationController?.setNavigationBarAppearanceWithoutSeparatorForStandardAppearance()
  }
  
  // MARK: - IBActions
  
  @IBAction func confirmButtonAction(_ sender: Any) {
    presenter.confirmButtonWasPressed()
  }
  
  @IBAction func denyButtonAction(_ sender: Any) {
    presenter.denyButtonWasPressed()
  }
  
  // MARK: - Private
  
  private func setAppearanceAfterPushNotification() {
    if isAfterPushNotification {
      navigationController?.setStatusBar(backgroundColor: Asset.Colors.background.color)
      navigationController?.navigationBar.tintColor = Asset.Colors.main.color
      navigationController?.navigationBar.barTintColor = Asset.Colors.background.color
      navigationController?.navigationBar.isTranslucent = true
    }
  }
  
  private func setStaticStrings() {
    denyButton.setTitle(L10n.buttonTitleDeny, for: .normal)
  }
  
  private func configureTableView() {
    tableView.registerNibForHeaderFooter(SignersHeaderView.self)
    tableView.registerNibForHeaderFooter(SignersFooterView.self)
    
    tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
    tableView.sectionFooterHeight = CGFloat.leastNormalMagnitude
    tableView.sectionHeaderHeight = UITableView.automaticDimension
  }
  
  private func setAppearance() {
    AppearanceHelper.set(confirmButton, with: L10n.buttonTitleConfirm)
  }
  
  private func setupNavigationBar() {
    let moreIcon = UIImage(named: "Icons/Other/icMore")?.withRenderingMode(.alwaysOriginal)
    let moreButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
    moreButton.layer.masksToBounds = true
    moreButton.setImage(moreIcon, for: .normal)
    moreButton.addTarget(self, action: #selector(moreDetailsButtonWasPressed), for: .touchUpInside)
    
    let rightBarButton = UIBarButtonItem(customView: moreButton)
    navigationItem.rightBarButtonItem = rightBarButton
  }
  
  @objc func moreDetailsButtonWasPressed() {
    let moreMenu = UIAlertController(title: nil,
                                     message: nil,
                                     preferredStyle: .actionSheet)
    
    let copySignedXdrAction = UIAlertAction(title: L10n.buttonTitleCopySignedXdr,
                                            style: .default) { _ in
      self.presenter.signedXdr()
    }
    
    let copyXdrAction = UIAlertAction(title: L10n.buttonTitleCopyXdr,
                                      style: .default) { _ in
      self.presenter.copyXdr()
    }
    
    let viewTransactionDetailsAction = UIAlertAction(title: L10n.buttonTitleViewTransactionDetails, style: .default) { _ in
      self.presenter.viewTransactionDetails()
    }
    
    let cancelAction = UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel)
          
    moreMenu.addAction(copyXdrAction)
    moreMenu.addAction(copySignedXdrAction)
    moreMenu.addAction(viewTransactionDetailsAction)
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

// MARK: - TransactionDetailsView

extension TransactionDetailsViewController: TransactionDetailsView {
  func setTitle(_ title: String) {
    navigationItem.title = title
  }
  
  func reloadData() {
    tableView.reloadData()
  }
  
  func reloadSignerListRow(_ row: Int) {
    let indexPath = IndexPath(row: row, section: TransactionDetailsSectionType.signers.index)
    tableView.reloadRows(at: [indexPath], with: .automatic)
  }
  
  func showConfirmationAlert(with description: String) {
    let alert = UIAlertController(title: L10n.textDenyDialogTitle,
                                  message: description, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleYes, style: .destructive, handler: { _ in
      self.presenter.confirmOperationWasConfirmed()
    }))
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel))
    
    present(alert, animated: true, completion: nil)
  }
  
  func setDenyingAlert() {
    let alert = UIAlertController(title: L10n.textDenyDialogTitle,
                                  message: L10n.textDenyDialogDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleYes, style: .destructive, handler: { _ in
      self.presenter.denyOperationWasConfirmed()
    }))
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel))
    
    present(alert, animated: true, completion: nil)
  }
  
  func setErrorAlert(for error: Error) {
    UIAlertController.defaultAlert(for: error, presentingViewController: self)
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
  
  func registerTableViewCell(with cellName: String) {
    tableView.register(UINib(nibName: cellName, bundle: nil),
                       forCellReuseIdentifier: cellName)
  }
  
  func setConfirmButtonWithError(isInvalid: Bool, withTextError: String?) {
    buttonsStackView.isHidden = false
    buttonsStackViewHeightConstraint.constant = 40.0
    
    guard isInvalid else {
      confirmButton.backgroundColor = Asset.Colors.main.color
      return
    }
    
    expiredErrorLabel.isHidden = false
    errorLabelHeightConstraint.constant = 30
    expiredErrorLabel.text = withTextError == nil ? L10n.textTransactionInvalidError : withTextError
    confirmButton.isEnabled = false
    confirmButton.backgroundColor = Asset.Colors.disabled.color
    confirmButton.setTitleColor(Asset.Colors.white.color, for: .normal)
  }
  
  func hideButtonsWithError(withTextError: String?) {
    expiredErrorLabel.isHidden = false
    errorLabelHeightConstraint.constant = 30
    expiredErrorLabel.text = withTextError == nil ? L10n.textTransactionInvalidError : withTextError
    buttonsStackView.isHidden = true
    buttonsStackViewHeightConstraint.constant = 0
  }

  func openTransactionListScreen() {
    navigationController?.popViewController(animated: true)
  }
  
  func copy(_ text: String) {
    let pasteboard = UIPasteboard.general
    pasteboard.string = text
    HUD.flash(.labeledSuccess(title: nil,
                              subtitle: L10n.animationCopy), delay: 1.0)
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
  
  func showAlert(text: String) {
    UIAlertController.defaultAlert(with: text, presentingViewController: self)
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
      
  func setSequenceNumberCountAlert() {
    let alert = UIAlertController(title: L10n.textSequenceNumberCountDialogTitle,
                                  message: L10n.textSequenceNumberCountDialogDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleConfirm, style: .destructive, handler: { _ in
      self.presenter.confirmOperationWasConfirmed()
    }))
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel))
    
    present(alert, animated: true, completion: nil)
  }
  
  func setTransactionAlreadySignedOrDeniedAlert() {
    let alert = UIAlertController(title: "", message: L10n.msgTransactionAlreadySignedOrDenied, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleOk, style: .cancel))
    
    present(alert, animated: true, completion: nil)
  }

  func showNoInternetConnectionAlert() {
    let alert = UIAlertController(title: L10n.textICloudSyncNoInternetConnectionAlertTitle, message: L10n.textICloudSyncNoInternetConnectionAlertDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleOk, style: .cancel))

    present(alert, animated: true, completion: nil)
  }
  
  func setButtons(isEnabled: Bool) {
    confirmButton.isEnabled = isEnabled
    denyButton.isEnabled = isEnabled
  }
  
  func showICloudSyncScreen() {
    let transactionConfirmationViewController = SettingsSelectionViewController.createFromStoryboard()
    transactionConfirmationViewController.screenType = .iCloudSync
    navigationController?.pushViewController(transactionConfirmationViewController, animated: true)
  }
}

// MARK: - UITableView

extension TransactionDetailsViewController: UITableViewDelegate, UITableViewDataSource {
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
    case .operation(let title):
      let cell: OperationTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
      cell.setOperationTitle(title)
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
    case .signer(let signerViewData):
      let cell: SignerTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
      cell.setData(viewData: signerViewData)
      cell.selectionStyle = .none
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView,
                 didSelectRowAt indexPath: IndexPath)
  {
    tableView.deselectRow(at: indexPath, animated: true)
    if let _ = tableView.cellForRow(at: indexPath) as? OperationTableViewCell {
      presenter.operationWasSelected(by: indexPath.item)
    } else if let cell = tableView.cellForRow(at: indexPath) as? OperationDetailsTableViewCell, cell.type == .publicKey {
      presenter.publicKeyWasSelected(key: cell.valueLabel.text)
    } else if let cell = tableView.cellForRow(at: indexPath) as? OperationDetailsTableViewCell, cell.type == .assetCode
    {
      presenter.assetCodeWasSelected(code: cell.valueLabel.text)
    } else if let cell = tableView.cellForRow(at: indexPath) as? SignerTableViewCell {
      presenter.signerWasSelected(cell.viewData)
    } else { return }
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
    case .operations:
      let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SignersHeaderView.reuseIdentifier) as! SignersHeaderView
      headerView.titleLabel.text = L10n.textOperationsHeaderTitle
      headerView.numberOfAcceptedSignaturesLabel.isHidden = true
      return headerView
    default:
      return nil
    }
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

// MARK: - NicknameDialogDelegate

extension TransactionDetailsViewController: NicknameDialogDelegate {
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
