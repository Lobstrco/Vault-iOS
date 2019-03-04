import UIKit

class HelpViewController: UIViewController, StoryboardCreation {

  static var storyboardType: Storyboards = .help
  
  @IBOutlet var tableView: UITableView!
  
  var sectionNames: [String] = []
  var sectionData: [[[String : Any]]] = []
  
  fileprivate let heigthOfHiddenRow: CGFloat = 60
  fileprivate let heigthOfVisibleRow: [[CGFloat]] = [[780, 1755, 1230, 780, 450, 830],
                                                     [1100, 1200, 870, 600],
                                                     [1140, 610, 1000, 590]]
  
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
    sectionNames = [L10n.helpFirstSectionTitle, L10n.helpSecondSectionTitle, L10n.helpThirdSectionTitle]
    sectionData = [[["isOpen": false, "data": [L10n.helpChapter1Title, L10n.helpChapter1Description]],
                    ["isOpen": false, "data": [L10n.helpChapter2Title, L10n.helpChapter2Description]],
                    ["isOpen": false, "data": [L10n.helpChapter3Title, L10n.helpChapter3Description]],
                    ["isOpen": false, "data": [L10n.helpChapter4Title, L10n.helpChapter4Description]],
                    ["isOpen": false, "data": [L10n.helpChapter5Title, L10n.helpChapter5Description]],
                    ["isOpen": false, "data": [L10n.helpChapter6Title, L10n.helpChapter6Description]]
                  ],
                  [["isOpen": false, "data": [L10n.helpChapter7Title, L10n.helpChapter7Description]],
                    ["isOpen": false, "data": [L10n.helpChapter8Title, L10n.helpChapter8Description]],
                    ["isOpen": false, "data": [L10n.helpChapter9Title, L10n.helpChapter9Description]],
                    ["isOpen": false, "data": [L10n.helpChapter10Title, L10n.helpChapter10Description]],
                  ],
                  [["isOpen": false, "data": [L10n.helpChapter11Title, L10n.helpChapter11Description]],
                    ["isOpen": false, "data": [L10n.helpChapter12Title, L10n.helpChapter12Description]],
                    ["isOpen": false, "data": [L10n.helpChapter13Title, L10n.helpChapter13Description]],
                    ["isOpen": false, "data": [L10n.helpChapter14Title, L10n.helpChapter14Description]]
                  ]]
  }
}

// MARK: - UITableView

extension HelpViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return heigthOfVisibleRow[section].count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "HelpTableViewCell") as! HelpTableViewCell
    let data = sectionData[indexPath.section][indexPath.item]["data"] as! [String]
    
    cell.titleLabel.text = data[0]
    cell.descriptionLabel.text = data[1]
    
    return cell
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return heigthOfVisibleRow.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let isOpen = sectionData[indexPath.section][indexPath.item]["isOpen"] as! Bool
    return isOpen ? heigthOfVisibleRow[indexPath.section][indexPath.item] : heigthOfHiddenRow
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let isOpen = sectionData[indexPath.section][indexPath.item]["isOpen"] as! Bool
    sectionData[indexPath.section][indexPath.item]["isOpen"] = !isOpen
    tableView.reloadRows(at: [indexPath], with: .automatic)
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
