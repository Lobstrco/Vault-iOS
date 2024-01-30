import UIKit
import PKHUD

protocol SettingsSelectionViewControllerDelegate: AnyObject {
  func updateSpamProtection(_ value: Bool?)
}

struct CellData {
  var title: String
  var isSelected: Bool
}

enum ScreenType {
  case promptTransactionDecisions
  case spamProtection
  case iCloudSync
}

class SettingsSelectionViewController: UIViewController, StoryboardCreation {
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var aboutLabel: UILabel!
  
  @IBOutlet var multipleDevicesView: UIView! {
    didSet {
      multipleDevicesView.isHidden = true
      multipleDevicesView.layer.cornerRadius = 5
      multipleDevicesView.layer.borderColor = Asset.Colors.grayOpacity15.color.cgColor
      multipleDevicesView.layer.borderWidth = 1
    }
  }
  
  @IBOutlet var multipleDevicesTitleLabel: UILabel! {
    didSet {
      multipleDevicesTitleLabel.text = L10n.textSettingsICloudSyncMultipleDevicesTitle
    }
  }
  
  @IBOutlet var multipleDevicesDescriptionLabel: UILabel! {
    didSet {
      multipleDevicesDescriptionLabel.text = L10n.textSettingsICloudSyncMultipleDevicesDescription
    }
  }
  
  static var storyboardType: Storyboards = .settings
  
  var screenType: ScreenType?
  
  var cellData: [CellData] = []
  var spamProtectionEnabled: Bool?
  
  @IBOutlet var tableView: UITableView!
  
  weak var delegate: SettingsSelectionViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
    addObservers()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setStatusBar(backgroundColor: Asset.Colors.background.color)
    navigationController?.setNavigationBarAppearance(backgroundColor: Asset.Colors.background.color)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarAppearanceWithoutSeparatorForStandardAppearance()
  }
  
  // MARK: - IBActions
  
  @IBAction func helpButtonAction(_ sender: Any) {
    helpButtonWasPressed()
  }
}

extension SettingsSelectionViewController {
  func configure() {
    navigationItem.largeTitleDisplayMode = .never
    if let type = screenType {
      switch type {
      case .promptTransactionDecisions:
        titleLabel.text = L10n.textSettingsTransactionsConfirmationsTitle
        aboutLabel.text = L10n.textSettingsTransactionsConfirmationsAbout
        
        cellData = [CellData(title: "Yes", isSelected: PromtForTransactionDecisionsHelper.isPromtTransactionDecisionsEnabled),
                    CellData(title: "No", isSelected: !PromtForTransactionDecisionsHelper.isPromtTransactionDecisionsEnabled)]
      case .spamProtection:
        titleLabel.text = L10n.textSettingsSpamProtectionTitle
        aboutLabel.text = L10n.textSettingsSpamProtectionAbout
        if let spamProtectionEnabledValue = spamProtectionEnabled {
          cellData = [CellData(title: "Yes", isSelected: !spamProtectionEnabledValue),
                      CellData(title: "No", isSelected: spamProtectionEnabledValue)]
        }
      case .iCloudSync:
        titleLabel.text = L10n.textSettingsICloudSyncTitle
        aboutLabel.text = L10n.textSettingsICloudSyncAbout
        
        cellData = [CellData(title: "Yes", isSelected: UserDefaultsHelper.isICloudSynchronizationEnabled),
                    CellData(title: "No", isSelected: !UserDefaultsHelper.isICloudSynchronizationEnabled)]
        
        setProgressAnimation(isEnabled: true)
        CloudKitNicknameHelper.checkIsICloudStatusAvaliable { isAvaliable in
          if isAvaliable {
            CloudKitNicknameHelper.isICloudDatabaseEmpty { result in
              self.setProgressAnimation(isEnabled: false)
              if result, !UserDefaultsHelper.isICloudSynchronizationEnabled {
                DispatchQueue.main.async {
                  self.multipleDevicesView.isHidden = false
                }
              }
            }
          } else {
            self.setProgressAnimation(isEnabled: false)
          }
        }
      }
    }
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
  }
  
  func setProgressAnimation(isEnabled: Bool) {
    DispatchQueue.main.async {
      isEnabled ? HUD.show(.labeledProgress(title: nil,
                                            subtitle: L10n.animationWaiting)) : HUD.hide()
    }
  }
  
  func helpButtonWasPressed() {
    guard let screenType = screenType else {
      let helpViewController = FreshDeskHelper.getHelpCenterController()
      navigationController?.present(helpViewController, animated: true)
      return
    }
    
    var article: FreshDeskArticle
    
    switch screenType {
    case .promptTransactionDecisions:
      article = .transactionConfirmations
    case .spamProtection:
      article = .allowUnsignedTransactions
    case .iCloudSync:
      article = .iCloudSync
    }
    
    let helpViewController = FreshDeskHelper.getFreshDeskArticleController(article: article)
    navigationController?.present(helpViewController, animated: true)
  }
}

extension SettingsSelectionViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionConfirmationCell")!
    cell.tintColor = Asset.Colors.main.color
    cell.textLabel?.text = cellData[indexPath.row].title
    cell.accessoryType = cellData[indexPath.row].isSelected ? .checkmark : .none
    
    return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cellData.count
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // unselect all fields
    cellData = cellData.map {
      var mutableData = $0
      mutableData.isSelected = false
      return mutableData
    }
    
    switch screenType {
    case .promptTransactionDecisions:
      let value = indexPath.row == 0 ? true : false
      if !UserDefaultsHelper.promtForTransactionDecisionsStatuses.isEmpty {
        UserDefaultsHelper.promtForTransactionDecisionsStatuses[UserDefaultsHelper.activePublicKey] = value
      }
      else {
        UserDefaultsHelper.isPromtTransactionDecisionsEnabled = value
      }
      cellData[indexPath.row].isSelected = true
      tableView.reloadData()
    case .spamProtection:
      spamProtectionEnabled = indexPath.row == 0 ? false : true
      cellData[indexPath.row].isSelected = true
      delegate?.updateSpamProtection(spamProtectionEnabled)
      tableView.reloadData()
    case .iCloudSync:
      guard UIDevice.isConnectedToNetwork else {
        showNoInternetConnectionAlert()
        return
      }
      let value = indexPath.row == 0 ? true : false
      guard value != UserDefaultsHelper.isICloudSynchronizationEnabled else {
        return
      }
      
      cellData[indexPath.row].isSelected = true
      tableView.reloadData()
      if value {
        CloudKitNicknameHelper.checkIsICloudStatusAvaliable(completion: { isAvaliable in
          DispatchQueue.main.async {
            if isAvaliable {
              self.iCloudSyncEnableDidTap()
            }
            else {
              self.showSignInToICloudAlert()
            }
          }
        })
      } else {
        UserDefaultsHelper.isICloudSynchronizationEnabled = false
      }
    default:
      break
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
}

extension SettingsSelectionViewController {
  func showICloudAlert() {
    let alert = UIAlertController(title: L10n.textICloudSyncAlertTitle,
                                  message: L10n.textICloudSyncAlertDescription, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleEnable, style: .destructive, handler: { _ in
      UserDefaultsHelper.isICloudSynchronizationEnabled = true
      AccountsStorageHelper.getFromICloudAndUpdateLocalAccounts()
    }))
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel, handler: { _ in
      UserDefaultsHelper.isICloudSynchronizationEnabled = false
      self.configure()
      self.tableView.reloadData()
    }))
    
    present(alert, animated: true, completion: nil)
  }
  
  func iCloudSyncEnableDidTap() {
    CloudKitNicknameHelper.isICloudDatabaseEmpty { cloudDatabaseIsEmpty in
      DispatchQueue.main.async {
        if !cloudDatabaseIsEmpty, !AccountsStorageHelper.getAllLocalAccounts().isEmpty {
          self.showICloudAlert()
        }
        else if cloudDatabaseIsEmpty, !AccountsStorageHelper.getAllLocalAccounts().isEmpty {
          UserDefaultsHelper.isICloudSynchronizationEnabled = true
          AccountsStorageHelper.saveAllLocalAccountsToICloud()
        }
        else if cloudDatabaseIsEmpty, AccountsStorageHelper.getAllLocalAccounts().isEmpty {
          UserDefaultsHelper.isICloudSynchronizationEnabled = true
        }
        else if !cloudDatabaseIsEmpty, AccountsStorageHelper.getAllLocalAccounts().isEmpty {
          UserDefaultsHelper.isICloudSynchronizationEnabled = true
          AccountsStorageHelper.getFromICloudAndUpdateLocalAccounts()
        }
      }
    }
  }
  
  func showSignInToICloudAlert() {
    let alert = UIAlertController(title: L10n.textSignInToICloudAlertTitle,
                                  message: L10n.textSignInToICloudAlertDescription, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleOk, style: .default, handler: { _ in
      UserDefaultsHelper.isICloudSynchronizationEnabled = false
      self.configure()
      self.tableView.reloadData()
    }))
    
    present(alert, animated: true, completion: nil)
  }
  
  func showNoInternetConnectionAlert() {
    let alert = UIAlertController(title: L10n.textICloudSyncNoInternetConnectionAlertTitle, message: L10n.textICloudSyncNoInternetConnectionAlertDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleOk, style: .cancel))

    present(alert, animated: true, completion: nil)
  }
}

extension SettingsSelectionViewController {
  func addObservers() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(onDidICloudSynchronizationEnable),
                                           name: .didICloudSynchronizationEnable,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                          selector: #selector(updateTableView),
                                          name: UIApplication.didBecomeActiveNotification,
                                          object: nil)
  }
 
  @objc func onDidICloudSynchronizationEnable() {
    configure()
    tableView.reloadData()
  }
  
  @objc func updateTableView() {
    if let topVC = UIApplication.getTopViewController() {
      if !(topVC is UIAlertController) {
        configure()
        tableView.reloadData()
      }
    }
  }
}
