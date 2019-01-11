import UIKit

protocol BiometricIDView: class {
  func setTitle(_ title: String)
  func setErrorAlert(for error: Error)
}

class BiometricIDViewController: UIViewController, StoryboardCreation {
  static var storyboardType: Storyboards = .biometricID

  var presenter: BiometricIDPresenter!

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    presenter = BiometricIDPresenterImpl(view: self)

    presenter.biometricIDViewDidLoad()
  }
}

// MARK: - IBActions

extension BiometricIDViewController {
  @IBAction func turnOnButtonAction(_ sender: UIButton) {
    presenter.turnOnButtonWasPressed()
  }

  @IBAction func skipButtonAction(_ sender: UIButton) {
    presenter.skipButtonWasPressed()
  }
}

// MARK: - BiometricIDView

extension BiometricIDViewController: BiometricIDView {
  func setTitle(_ title: String) {
    self.title = title
  }

  func setErrorAlert(for error: Error) {
    UIAlertController.defaultAlert(for: error, presentingViewController: self)
  }
}
