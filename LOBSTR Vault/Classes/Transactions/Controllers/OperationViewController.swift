import UIKit
import PKHUD
import stellarsdk

class OperationViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .transactions
  
  var presenter: OperationPresenter!
  
  @IBOutlet var tableView: UITableView!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerNibForHeaderFooter(SignersHeaderView.self)
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
  
  func copy(_ text: String) {
    let pasteboard = UIPasteboard.general
    pasteboard.string = text
    HUD.flash(.labeledSuccess(title: nil,
                              subtitle: L10n.animationCopy), delay: 1.0)
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
    case .additionalInformation((let name, let value)):
      let cell: OperationDetailsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
      if value.isShortStellarPublicAddress {
        cell.type = .publicKey
      }
      cell.setData(title: name, value: value)
      cell.selectionStyle = .none
      return cell
    case .operationDetail((let name, let value, let isAssetCode)):
      let cell: OperationDetailsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
      if name == "Claimants" {
        cell.type = .claimants
      }
      if value.isShortStellarPublicAddress {
        cell.type = .publicKey
      }
      if isAssetCode {
        cell.type = .assetCode
      }
      cell.setData(title: name, value: value)
      cell.selectionStyle = .none
      return cell
    case .additionalInformation((let name, let value)):
      let cell: OperationDetailsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
      if value.isShortStellarPublicAddress {
        cell.type = .publicKey
      }
      cell.setData(title: name, value: value)
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
    return presenter.sections[indexPath.section].type.rowHeight
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return presenter.sections[section].type.headerHeight
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
    default:
      return nil
    }
  }
  
  func tableView(_ tableView: UITableView,
                 didSelectRowAt indexPath: IndexPath) {
    if let cell = tableView.cellForRow(at: indexPath) as? OperationDetailsTableViewCell, cell.type == .publicKey {
      tableView.deselectRow(at: indexPath, animated: true)
      presenter.publicKeyWasSelected(key: cell.valueLabel.text)
    } else if let cell = tableView.cellForRow(at: indexPath) as? OperationDetailsTableViewCell, cell.type == .assetCode {
      presenter.assetCodeWasSelected(code: cell.valueLabel.text)
    } else { return }
  }
}
