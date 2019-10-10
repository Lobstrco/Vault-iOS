import UIKit

class OperationViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .transactions
  
  var presenter: OperationPresenter!
  
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(UINib(nibName: "OperationDetailsTableViewCell", bundle: nil),
                       forCellReuseIdentifier: "OperationDetailsTableViewCell")
    
    presenter.operationViewDidLoad()
    configureTableView()
    
    setStaticStrings()
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
    
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  private func setStaticStrings() {
    navigationItem.title = L10n.navTitleOperationDetails
  }
}

// MARK: - OperationDetailsView

extension OperationViewController: OperationDetailsView {
  
  func setListOfOperationDetails() {
    tableView.reloadData()
  }
}

// MARK: - UITableView

extension OperationViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.countOfOperationProperties
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "OperationDetailsTableViewCell",
                                             for: indexPath) as! OperationDetailsTableViewCell
    presenter.configure(cell, forRow: indexPath.item)
    cell.selectionStyle = .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
  
}
