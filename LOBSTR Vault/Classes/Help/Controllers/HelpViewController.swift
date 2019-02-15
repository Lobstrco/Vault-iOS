import UIKit

class HelpViewController: UIViewController, StoryboardCreation {

  static var storyboardType: Storyboards = .help
  
  @IBOutlet var tableView: UITableView!
  
  var sectionNames: [String] = []
  var sectionData: [[[String : Any]]] = []
  
  fileprivate let heigthOfHiddenRow: CGFloat = 60
  fileprivate let heigthOfVisibleRow: CGFloat = 250
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setStaticStrings()
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    tabBarController?.tabBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    tabBarController?.tabBar.isHidden = false
  }
}

// MARK: - Private

extension HelpViewController {
  
  private func setStaticStrings() {
    sectionNames = [L10n.helpFirstSectionTitle, L10n.helpSecondSectionTitle]
    sectionData = [[["isOpen": false, "data": [L10n.helpMnemonicTitle, L10n.helpMnemonicDescription]],
                    ["isOpen": false, "data": [L10n.helpPublicKeyTitle, L10n.helpMnemonicDescription]]],
                   [["isOpen": false, "data": [L10n.helpTransactionTitle, L10n.helpTransactionDescription]],
                    ["isOpen": false, "data": [L10n.helpPasswordTitle, L10n.helpPasswordDescription]]]]
  }
}

// MARK: - UITableView

extension HelpViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "HelpTableViewCell") as! HelpTableViewCell
    let data = sectionData[indexPath.section][indexPath.item]["data"] as! [String]
    
    cell.titleLabel.text = data[0]
    cell.descriptionLabel.text = data[1]
    
    return cell
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let isOpen = sectionData[indexPath.section][indexPath.item]["isOpen"] as! Bool
    return isOpen ? heigthOfVisibleRow : heigthOfHiddenRow
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let isOpen = sectionData[indexPath.section][indexPath.item]["isOpen"] as! Bool
    sectionData[indexPath.section][indexPath.item]["isOpen"] = !isOpen
    
    tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 42
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView()
    headerView.backgroundColor = Asset.Colors.background.color
    
    let titleLabel = UILabel()
    titleLabel.text = sectionNames[section]
    titleLabel.font = UIFont.systemFont(ofSize: 13)
    titleLabel.textColor = Asset.Colors.grayOpacity70.color
    
    headerView.addSubview(titleLabel)
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16).isActive = true
    titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -6).isActive = true
    
    return headerView
  }
  
}
