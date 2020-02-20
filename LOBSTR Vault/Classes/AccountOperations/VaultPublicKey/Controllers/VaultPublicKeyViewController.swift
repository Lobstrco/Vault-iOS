import PKHUD
import UIKit

class VaultPublicKeyViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .vaultPublicKey
  
  var presenter: VaultPublicKeyPresenter!
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var nextButton: UIButton!
}

// MARK: - Lifecycle

extension VaultPublicKeyViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter = VaultPublicKeyPresenterImpl(view: self,
                                            navigationController: navigationController!)
    
    presenter.vaultPublicKeyViewDidLoad()
    setAppearance()
  }
}

// MARK: - IBActions

extension VaultPublicKeyViewController {
  @IBAction func nextButtonAction(_ sender: UIButton) {
    presenter.nextButtonWasPressed()
  }
  
  @IBAction func helpButtonAction(_ sender: Any) {
    presenter.helpButtonWasPressed()
  }
}

// MARK: - Private

extension VaultPublicKeyViewController {
  private func setAppearance() {
    AppearanceHelper.set(nextButton, with: L10n.buttonTitleNext)
    navigationItem.hidesBackButton = true
    navigationController?.navigationBar.prefersLargeTitles = false
  }
}

// MARK: - UITableViewDataSource

extension VaultPublicKeyViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return presenter.sections.count
  }
  
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return presenter.sections[section].rows.count
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = presenter.sections[indexPath.section]
    let row = section.rows[indexPath.row]
    
    switch row {
      case .usingLobstrWallet(let lobstrCheckResult):
        let cell: UsingLobstrWalletTableViewCell =
          tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.delegate = self
        cell.setInformationAccording(lobstrCheckResult)
        return cell
      case .usingDifferentService(let publicKey):
        let cell: UsingDifferentServiceTableViewCell =
          tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.delegate = self
        cell.publicKeyLabel.text = publicKey.getTruncatedPublicKey(numberOfCharacters: 14)
        return cell
    }
  }
}

// MARK: - UITableViewDelegate

extension VaultPublicKeyViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat {
    let section = presenter.sections[indexPath.section]
    let row = section.rows[indexPath.row]
    return row.height
  }
}

// MARK: - UsingDifferentServiceTableViewCellDelegate

extension VaultPublicKeyViewController: UsingDifferentServiceTableViewCellDelegate {
  func copyKeyButtonDidPress() {
    presenter.copyKeyButtonWasPressed()
    HUD.flash(.labeledSuccess(title: nil, subtitle: L10n.animationCopy), delay: 1.0)
  }
  
  func showQRCodeButtonDidPress() {
    presenter.showQRCodeButtonWasPressed()
  }
}

// MARK: - UsingLobstrWalletTableViewCellDelegate

extension VaultPublicKeyViewController: UsingLobstrWalletTableViewCellDelegate {
  func actionButtonWasPressed() {
    presenter.actionButtonWasPressed()
  }
}

// MARK: - VaultPublicKeyView

extension VaultPublicKeyViewController: VaultPublicKeyView {
  
  func reloadTable() {
    tableView.reloadData()
  }
  
  func setProgressAnimation(isDisplay: Bool) {
    isDisplay ? HUD.show(.labeledProgress(title: nil,
                                          subtitle: L10n.animationWaiting)) : HUD.hide()
  }
  
  func setPublicKeyPopover(_ popover: CustomPopoverViewController) {
    present(popover, animated: true, completion: nil)
  }
}
