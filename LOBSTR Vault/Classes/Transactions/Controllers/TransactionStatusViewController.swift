import UIKit

class TransactionStatusViewController: UIViewController, StoryboardCreation {
  
  static var storyboardType: Storyboards = .transactions

  @IBOutlet var statusLabel: UILabel!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.hidesBackButton = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    tabBarController?.tabBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    tabBarController?.tabBar.isHidden = false
  }
  
  // MARK: - IBActions
  
  @IBAction func closeButtonAction(_ sender: Any) {
    tabBarController?.tabBar.isHidden = false
    navigationController?.popToRootViewController(animated: true)
  }
}
