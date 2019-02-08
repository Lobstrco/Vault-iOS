import UIKit
import PKHUD

class RecheckViewController: UIViewController, StoryboardCreation {

  static var storyboardType: Storyboards = .recheck
  
  @IBOutlet weak var recheckButton: UIButton!
  @IBOutlet weak var recheckInfoLabel: UILabel!
  
  var presenter: RecheckPresenter!  
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setApperance()
    setStaticStrings()
    
    presenter = RecheckPresenterImpl(view: self)
  }

  // MARK: - IBAction
  
  @IBAction func recheckButtonAction(_ sender: Any) {
    presenter.recheckButtonWasPressed()
  }
  
  @IBAction func logoutButtonAction(_ sender: Any) {
    presenter.logoutButtonWasPressed()
  }
  
  // MARK: - Private
  
  private func setApperance() {
    AppearanceHelper.set(recheckButton, with: L10n.buttonTitleReCheck)
  }
  
  
  private func setStaticStrings() {
    recheckInfoLabel.text = L10n.textRecheckInfo
  }
}

// MARK: - RecheckView

extension RecheckViewController: RecheckView {
  func setProgressAnimation(isDisplay: Bool) {
    isDisplay ? HUD.show(.labeledProgress(title: nil, subtitle: L10n.animationWaiting)) : HUD.hide()
  }
  
  func setLogoutAlert() {
    let alert = UIAlertController(title: L10n.logoutAlertTitle, message: L10n.logoutAlertMessage, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: L10n.buttonTitleLogout, style: .destructive, handler: { _ in
      self.presenter.logoutOperationWasConfirmed()
    }))
    
    alert.addAction(UIAlertAction(title: L10n.buttonTitleCancel, style: .cancel))
    
    self.present(alert, animated: true, completion: nil)
  }
}
