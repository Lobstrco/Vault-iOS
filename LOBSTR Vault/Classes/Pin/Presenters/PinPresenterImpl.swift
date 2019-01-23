import Foundation
import UIKit

protocol PinView: class {
  func setTitle(_ title: String)
  func fillPinDot(at index: Int)
  func clearPinDot(at index: Int)
  func shakePinView()
}

class PinPresenterImpl: PinPresenter {
  var pin: String = ""
  let pinLength = 6
  
  var mode: PinMode
  
  weak var view: PinView?
  
  private let pinManager: PinManager
  private var biometricAuthManager: BiometricAuthManager
  
  // MARK: - Init
  
  init(view: PinView,
       mode: PinMode,
       pinManager: PinManager = PinManagerImpl(),
       biometricAuthManager: BiometricAuthManager = BiometricAuthManagerImpl()) {
    self.view = view
    self.mode = mode
    self.pinManager = pinManager
    self.biometricAuthManager = biometricAuthManager
  }
  
  // MARK: - PinPresenter
  
  func pinViewDidLoad() {
    switch mode {
    case .enterPin:
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
      view?.setTitle(L10n.navTitleCreatePasscode)
    case .createPinSecondStep:
      view?.setTitle(L10n.navTitleReenterPasscode)
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
          transitionToBiometricID()
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
    
    let currentPinViewController = view as! PinViewController
    currentPinViewController.navigationController?.pushViewController(pinViewController,
                                            animated: true)
  }
  
  func transitionToCreatePinSecondStep() {
    let pinViewController = PinViewController.createFromStoryboard()    
    
    pinViewController.mode = .createPinSecondStep(pin)
    
    let currentPinViewController = view as! PinViewController
    currentPinViewController.navigationController?.pushViewController(pinViewController,
                                            animated: true)
  }
  
  func transitionToBiometricID() {
    let biometricIDViewController = BiometricIDViewController.createFromStoryboard()
    
    let pinViewController = view as! PinViewController
    pinViewController.navigationController?.pushViewController(biometricIDViewController,
                                            animated: true)
  }
}
