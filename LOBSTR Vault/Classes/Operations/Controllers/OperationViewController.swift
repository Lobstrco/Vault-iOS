import UIKit

class OperationViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .transactions
  
  var presenter = OperationPresenterImpl()
  
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureTableView()
    
    presenter.initData(view: self)
    presenter.operationViewDidLoad()
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "OperationDetailsTableViewCell", for: indexPath) as! OperationDetailsTableViewCell
    presenter.configure(cell, forRow: indexPath.item)
    
    return cell
  }
  
}
