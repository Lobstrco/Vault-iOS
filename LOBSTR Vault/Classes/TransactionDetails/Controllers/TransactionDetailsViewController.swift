import UIKit
import PKHUD
import stellarsdk

class TransactionDetailsViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .transactions
  var presenter: TransactionDetailsPresenter!
  var afterPushNotification: Bool = false
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var confirmButton: UIButton!
  @IBOutlet weak var denyButton: UIButton!
  @IBOutlet weak var expiredErrorLabel: UILabel!
  
  @IBOutlet weak var errorLabelHeightConstraint: NSLayoutConstraint!
  
  
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
    if afterPushNotification {
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
    
    tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
    tableView.sectionFooterHeight = CGFloat.leastNormalMagnitude
    tableView.sectionHeaderHeight = UITableView.automaticDimension
  }
  
  private func setAppearance() {
    AppearanceHelper.set(confirmButton, with: L10n.buttonTitleConfirm)
  }
  
  private func setupNavigationBar() {
    let moreIcon = UIImage(named: "Icons/Other/icMore")?.withRenderingMode(.alwaysOriginal)
    let moreButton = UIBarButtonItem(image: moreIcon, style: .plain, target: self, action: #selector(moreDetailsButtonWasPressed))
  
    navigationItem.setRightBarButton(moreButton, animated: false)
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
  
  func setConfirmationAlert() {
    let alert = UIAlertController(title: L10n.textDenyDialogTitle,
                                  message: L10n.textConfirmDialogDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleYes, style: .destructive, handler: { _ in
      self.presenter.confirmOperationWasConfirmed()
    }))
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  func setDenyingAlert() {
    let alert = UIAlertController(title: L10n.textDenyDialogTitle,
                                  message: L10n.textDenyDialogDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleYes, style: .destructive, handler: { _ in
      self.presenter.denyOperationWasConfirmed()
    }))
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  func setErrorAlert(for error: Error) {
    UIAlertController.defaultAlert(for: error, presentingViewController: self)
  }
  
  func setProgressAnimation(isEnable: Bool) {
    DispatchQueue.main.async {
      self.navigationItem.hidesBackButton = isEnable
      if let topVC = UIApplication.getTopViewController() {
        if !(topVC is PinEnterViewController) {
          isEnable ? HUD.show(.labeledProgress(title: nil,
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
    case .publicKey:
      if let key = value as? String {
        let copyAction = UIAlertAction(title: L10n.buttonTextCopy,
                                       style: .default) { _ in
          self.presenter.copyPublicKey(key)
        }
        
        let openExplorerAction = UIAlertAction(title: L10n.buttonTextOpenExplorer,
                                               style: .default) { _ in
          self.presenter.explorerPublicKey(key)
        }
                    
        moreMenu.addAction(openExplorerAction)
        moreMenu.addAction(copyAction)
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
      if name.contains("Flags") {
        cell.type = .flags
      }
      if isPublicKey {
        cell.type = .publicKey
      }
//      if value.isShortStellarPublicAddress {
//        cell.type = .publicKey
//      }
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
                 didSelectRowAt indexPath: IndexPath) {
    if let _ = tableView.cellForRow(at: indexPath) as? OperationTableViewCell {
      tableView.deselectRow(at: indexPath, animated: true)
      presenter.operationWasSelected(by: indexPath.item)
    } else if let cell = tableView.cellForRow(at: indexPath) as? OperationDetailsTableViewCell, cell.type == .publicKey {
      tableView.deselectRow(at: indexPath, animated: true)
      presenter.publicKeyWasSelected(key: cell.valueLabel.text)
    } else if let cell = tableView.cellForRow(at: indexPath) as? OperationDetailsTableViewCell, cell.type == .assetCode
    {
      tableView.deselectRow(at: indexPath, animated: true)
      presenter.assetCodeWasSelected(code: cell.valueLabel.text)
    } else { return }
  }
  
  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch presenter.sections[indexPath.section].rows[indexPath.row] {
    case .operationDetail((let name, let value, _, _, _)):
      if name.contains("Flags") {
        let separateCount =  value.components(separatedBy:"\n").count - 1
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
}
