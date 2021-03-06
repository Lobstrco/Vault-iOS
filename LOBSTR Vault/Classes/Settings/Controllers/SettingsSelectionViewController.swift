import UIKit

protocol SettingsSelectionViewControllerDelegate {
  func updateSpamProtection(_ value: Bool?)
}

struct CellData {
  var title: String
  var isSelected: Bool
}

enum ScreenType {
  case promptTransactionDecisions
  case spamProtection
}

class SettingsSelectionViewController: UIViewController, StoryboardCreation {
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var aboutLabel: UILabel!
  
  static var storyboardType: Storyboards = .settings
  
  var screenType: ScreenType?
  
  var cellData: [CellData] = []
  var spamProtectionEnabled: Bool?
  
  @IBOutlet var tableView: UITableView!
  
  var delegate: SettingsSelectionViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
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
        
        cellData = [CellData(title: "Yes", isSelected: UserDefaultsHelper.isPromtTransactionDecisionsEnabled),
                        CellData(title: "No", isSelected: !UserDefaultsHelper.isPromtTransactionDecisionsEnabled)]
      case .spamProtection:
        titleLabel.text = L10n.textSettingsSpamProtectionTitle
        aboutLabel.text = L10n.textSettingsSpamProtectionAbout
        if let spamProtectionEnabledValue = spamProtectionEnabled {
          cellData = [CellData(title: "Yes", isSelected: !spamProtectionEnabledValue),
                          CellData(title: "No", isSelected: spamProtectionEnabledValue)]
        }
      }
    }
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
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
    cellData = cellData.map({
      var mutableData = $0
      mutableData.isSelected = false
      return mutableData
    })
    
    switch screenType {
    case .promptTransactionDecisions:
      UserDefaultsHelper.isPromtTransactionDecisionsEnabled = indexPath.row == 0 ? true : false
      cellData[indexPath.row].isSelected = true
      tableView.reloadData()
    case .spamProtection:
      spamProtectionEnabled = indexPath.row == 0 ? false : true
      cellData[indexPath.row].isSelected = true
      delegate?.updateSpamProtection(spamProtectionEnabled)
      tableView.reloadData()
    default:
      break
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
}
