import UIKit

protocol SettingsView: class {
  func showSettings()
}

class SettingsViewController: UIViewController,
  UITableViewDelegate, UITableViewDataSource, StoryboardCreation, SettingsView {
  
  static var storyboardType: Storyboards = .settings
  
  @IBOutlet var tableView: UITableView!
  
  var presenter: SettingsPresenter!

  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    presenter = SettingsPresenterImpl(view: self)
    
    presenter.settingsViewDidLoad()
  }
  
  // MARK: - UITableViewDelegate
  
  func tableView(_ tableView: UITableView,
                 heightForHeaderInSection section: Int) -> CGFloat {
    return tableView.sectionHeaderHeight
  }
  
  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 44.0
  }
  
  // MARK: - UITableViewDataSource
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return presenter.numberOfSections()
  }
  
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return presenter.numberOfRows(in: section)
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let row = presenter.row(for: indexPath)

    switch row {
    case .publicKey:
      let cell =
        tableView.dequeueReusableCell(forIndexPath: indexPath)
        as PublicKeyTableViewCell
      
      presenter.configure(publicKeyCell: cell)
      
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView,
                 titleForHeaderInSection section: Int) -> String? {
    let title = presenter.title(for: section)
    return title
  }
  
  // MARK: - SettingsView
  
  func showSettings() {
    tableView.reloadData()
  }
}
