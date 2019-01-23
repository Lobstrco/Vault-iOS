import UIKit

class TransactionListViewController: UIViewController {

  var presenter: TransactionListPresenter!
  
  @IBOutlet var tableView: UITableView!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter = TransactionListPresenterImpl(view: self)
    presenter.transactionListViewDidLoad()
    
    configureTableView()
  }
  
  // MARK: - Public
  
  func configureTableView() {
    tableView.tableFooterView = UIView()
    tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    
    self.navigationController?.navigationBar.prefersLargeTitles = true
  }
}

// MARK: - TransactionListView

extension TransactionListViewController: TransactionListView {
  
  func setTransactionList() {
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.reloadData()
  }
  
  func setErrorAlert(for error: Error) {
    UIAlertController.defaultAlert(for: error, presentingViewController: self)
  }
}

// MARK: - UITableView

extension TransactionListViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.countOfTransactions
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "TransactionListTableViewCell") as! TransactionListTableViewCell
    presenter.configure(cell, forRow: indexPath.item)
    
    let borderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 81))
    borderView.backgroundColor = Asset.Colors.white.color
    borderView.clipsToBounds = true
    borderView.layer.cornerRadius = 6
    borderView.layer.borderWidth = 1
    borderView.layer.borderColor = Asset.Colors.cellBorder.color.cgColor
    
    borderView.layer.addBorder(edge: .left, color: Asset.Colors.main.color, thickness: 5)
    
    cell.content.layer.shadowColor = UIColor.black.cgColor
    cell.content.layer.shadowOffset = CGSize(width: 0, height: 2)
    cell.content.layer.shadowOpacity = 0.1
    cell.content.layer.shadowRadius = 2
    
    cell.content.addSubview(borderView)
    cell.content.sendSubviewToBack(borderView)
    
    cell.selectionStyle = UITableViewCell.SelectionStyle.none
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    presenter.transactionWasSelected(with: indexPath.item)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 88
  }
  
}

extension CALayer {
  
  func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
    
    var border = CALayer()
    
    switch edge {
    case UIRectEdge.top:
      border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
      break
    case UIRectEdge.bottom:
//      border.frame = CGRect(0, CGRectGetHeight(self.frame) - thickness, UIScreen.main.bounds.width, thickness)
      break
    case UIRectEdge.left:
      border.frame = CGRect(x: 0, y: 0, width: thickness, height: 88)
      break
    case UIRectEdge.right:
//      border.frame = CGRect(CGRectGetWidth(self.frame) - thickness, 0, thickness, CGRectGetHeight(self.frame))
      break
    default:
      break
    }
    
    border.backgroundColor = color.cgColor;
    
    self.addSublayer(border)
  }
  
}
