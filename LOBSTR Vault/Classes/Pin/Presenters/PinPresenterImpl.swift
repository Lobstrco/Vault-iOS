import Foundation
import UIKit

class PinPresenterImpl: PinPresenter {
  var pin: String = ""
  let pinLength = 6
  
  var mode: PinMode
  
  weak var view: PinView?
  
  private let pinManager: PinManager
  private var biometricAuthManager: BiometricAuthManager
  
  let navigationController: UINavigationController
  
  // MARK: - Init
  
  init(view: PinView,
       navigationController: UINavigationController,
       mode: PinMode,
       pinManager: PinManager = PinManagerImpl(),
       biometricAuthManager: BiometricAuthManager = BiometricAuthManagerImpl()) {
    self.view = view
    self.mode = mode
    self.navigationController = navigationController
    self.pinManager = pinManager
    self.biometricAuthManager = biometricAuthManager
  }
  
  // MARK: - PinPresenter
  
  func pinViewDidLoad() {
    switch mode {
    case .enterPin:
      view?.setTitle("Enter Pin")
      
      guard biometricAuthManager.isBiometricAuthEnabled else { return }
      
      biometricAuthManager.authenticateUser { [weak self] result in
        switch result {
        case .success:
          self?.transitionToHomeScreen()
        case .failure:
          break
        }
      }
    
    case .createPinFirstStep:
      view?.setTitle("Create Pin")
    case .createPinSecondStep:
      view?.setTitle("Confirm Pin")
    default:
      break
    }
  }
  
  func digitButtonWasPressed(with digit: Int) {
    guard pin.count < pinLength else { return }
    view?.fillPinDot(at: pin.count)
    pin += String(digit)
    
    if pin.count == pinLength {
      switch mode {
      case .createPinFirstStep:
        transitionToCreatePinSecondStep()
        
      case .createPinSecondStep(let pinFromFirstStep):
        
        if pinManager.validate(pinFromFirstStep, pin), pinManager.store(pin) {
          updateToken()
        } else {
          view?.shakePinView()
        }
        
      case .enterPin:
        
        validateEnteredPin()
        
      case .changePin:
        
        validateChangedPin()
        
      case .undefined:
        fatalError()
      }
    }
  }
  
  func removeButtonWasPressed() {
    guard pin.count > 0 else { return }
    pin.removeLast()
    view?.clearPinDot(at: pin.count)
  }
  
  // MARK: - Private
  
  private func validateEnteredPin() {
    guard let storedPin = pinManager.getPin() else { return }
    
    if pinManager.validate(storedPin, pin) == true {
      transitionToHomeScreen()
    } else {
      view?.shakePinView()
    }
  }
  
  private func validateChangedPin() {
    guard let storedPin = pinManager.getPin() else { return }
    
    if pinManager.validate(storedPin, pin) == true {
      transitionToCreatePinFirstStep()
    } else {
      view?.shakePinView()
    }
  }
  
  private func updateToken() {
    AuthenticationService().updateToken { result in
      switch result {
      case .success:
        self.transitionToBiometricID()
      case .failure(let error):
        print("Couldn't get token. \(error)")
      }
    }
  }
}

// MARK: - Navigation

extension PinPresenterImpl {
  func transitionToHomeScreen() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
      else { return }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      appDelegate.applicationCoordinator.showHomeScreen()
    }
  }
  
  func transitionToCreatePinFirstStep() {
    let pinViewController = PinViewController.createFromStoryboard()
    
    pinViewController.mode = .createPinFirstStep
    
    navigationController.pushViewController(pinViewController,
                                            animated: true)
  }
  
  func transitionToCreatePinSecondStep() {
    let pinViewController = PinViewController.createFromStoryboard()    
    
    pinViewController.mode = .createPinSecondStep(pin)
    
    navigationController.pushViewController(pinViewController,
                                            animated: true)
  }
  
  func transitionToBiometricID() {
    let biometricIDViewController = BiometricIDViewController.createFromStoryboard()
    
    navigationController.pushViewController(biometricIDViewController,
                                            animated: true)
  }
}
