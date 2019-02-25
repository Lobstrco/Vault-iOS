import PKHUD
import UIKit

protocol SignerDetailsView: class {
  func setAccountList(isEmpty: Bool)
  func setProgressAnimation()
  func copy(_ publicKey: String)
}

class SignerDetailsTableViewController: UITableViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .signerDetails
  
  var emptyStateLabel: UILabel?
  var presenter: SignerDetailsPresenter!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setAppearance()
    presenter = SignerDetailsPresenterImpl(view: self)
    presenter.signerDetailsViewDidLoad()
    tableView.tableFooterView = UIView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    tabBarController?.tabBar.isHidden = false
  }
  
  // MARK: - Private
  
  private func setAppearance() {
    navigationItem.title = L10n.navTitleSettingsSignedAccounts
  }
  
  private func setEmptyStateLabel() {
    emptyStateLabel = UILabel()
    
    guard let emptyStateLabel = emptyStateLabel else {
      return
    }
    
    view.addSubview(emptyStateLabel)
    
    emptyStateLabel.text = L10n.textEmptyStateSignedAccounts
    emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
    emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }
  
  func removeEmptyStateLabel() {
    emptyStateLabel?.removeFromSuperview()
  }
}

// MARK: - UITableView

extension SignerDetailsTableViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.countOfAccounts
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SignerDetailsViewCell", for: indexPath) as! SignerDetailsTableViewCell
    presenter.configure(cell, forRow: indexPath.item)
    cell.delegate = self
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
}

// MARK: - SignerDetailsTableViewCellDelegate

extension SignerDetailsTableViewController: SignerDetailsTableViewCellDelegate {
  func menuButtonDidTap(in cell: SignerDetailsTableViewCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    
    let moreMenu = UIAlertController(title: nil,
                                     message: nil,
                                     preferredStyle: .actionSheet)
    
    let copyAction = UIAlertAction(title: "Copy public key",
                                   style: .default) { _ in
      self.presenter.copyAlertActionWasPressed(for: indexPath.row)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    
    moreMenu.addAction(copyAction)
    moreMenu.addAction(cancelAction)
    
    present(moreMenu, animated: true, completion: nil)
  }
}

// MARK: - SignerDetailsView

extension SignerDetailsTableViewController: SignerDetailsView {
  func setAccountList(isEmpty: Bool) {
    tableView.reloadData()
    HUD.hide()
    
    if isEmpty {
      setEmptyStateLabel()
    }
  }
  
  func setProgressAnimation() {
    HUD.show(.labeledProgress(title: nil, subtitle: L10n.animationWaiting))
  }
  
  func copy(_ publicKey: String) {
    let pasteboard = UIPasteboard.general
    pasteboard.string = publicKey
    HUD.flash(.labeledSuccess(title: nil,
                              subtitle: L10n.animationCopy), delay: 1.0)
  }
}
