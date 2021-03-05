import UIKit

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
    case .operationDetail(let name, let value):
      let cell: OperationDetailsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
      
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
    guard presenter.sections[section].type == .signers else {
      return nil
    }
    
    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SignersHeaderView.reuseIdentifier) as! SignersHeaderView
    headerView.numberOfAcceptedSignaturesLabel.text = "\(presenter.numberOfAcceptedSignatures) of \(presenter.numberOfNeededSignatures)"
    return headerView
  }
}
