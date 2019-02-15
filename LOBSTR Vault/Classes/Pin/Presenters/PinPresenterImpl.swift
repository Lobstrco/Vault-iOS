import Foundation
import UIKit

protocol PinView: class {
  func setTitle(_ title: String)
  func fillPinDot(at index: Int)
  func clearPinDot(at index: Int)
  func clearPinDots()
  func shakePinView()
  func setNavigationItem()
  func hideBackButton()  
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
      view?.hideBackButton()
    case .createPinSecondStep:
      view?.setTitle(L10n.navTitleReenterPasscode)
    case .changePin:
      view?.setNavigationItem()
      view?.setTitle(L10n.navTitleChangePasscodeEnterOld)
    case .createNewPinFirstStep:
      view?.setTitle(L10n.navTitleChangePasscodeEnterNew)
    case .createNewPinSecondStep(_):
      view?.setTitle(L10n.navTitleChangePasscodeConfirmNew)
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
        transitionToCreatePinSecondStep(with: .createPinSecondStep(pin))
      case .createPinSecondStep(let pinFromFirstStep):
        if pinManager.validate(pinFromFirstStep, pin), pinManager.store(pin) {
          transitionToBiometricID()
        } else {
          resetPinAfterWrongDialing()
        }
      case .enterPin:
        validateEnteredPin()
      case .changePin:
        validateChangedPin()
      case .createNewPinFirstStep:
        transitionToCreatePinSecondStep(with: .createNewPinSecondStep(pin))
      case .createNewPinSecondStep(let pinFromFirstStep):
        if pinManager.validate(pinFromFirstStep, pin), pinManager.store(pin) {
          transitionToSettings()
        } else {
          resetPinAfterWrongDialing()
        }
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
  
  func helpButtonWasPressed() {
    let helpViewController = HelpViewController.createFromStoryboard()
    
    let pinViewController = view as! PinViewController
    pinViewController.navigationController?.pushViewController(helpViewController, animated: true)
  }
  
  // MARK: - Private
  
  private func resetPinAfterWrongDialing() {
    view?.shakePinView()
    pin.removeAll()
    view?.clearPinDots()
  }
  
  private func validateEnteredPin() {
    guard let storedPin = pinManager.getPin() else { return }
    
    if pinManager.validate(storedPin, pin) == true {
      transitionToHomeScreen()
    } else {
      resetPinAfterWrongDialing()
    }
  }
  
  private func validateChangedPin() {
    guard let storedPin = pinManager.getPin() else { return }
    
    if pinManager.validate(storedPin, pin) == true {
      transitionToCreatePinFirstStep(with: .createNewPinFirstStep)
    } else {
      resetPinAfterWrongDialing()
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
  
  func transitionToCreatePinFirstStep(with mode: PinMode) {
    let pinViewController = PinViewController.createFromStoryboard()
    pinViewController.mode = mode
    
    let currentPinViewController = view as! PinViewController
    currentPinViewController.navigationController?.pushViewController(pinViewController,
                                            animated: true)
  }
  
  func transitionToCreatePinSecondStep(with mode: PinMode) {
    let pinViewController = PinViewController.createFromStoryboard()
    pinViewController.mode = mode
    
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
  
  func transitionToSettings() {
    let pinViewController = view as! PinViewController
    pinViewController.navigationController?.popToRootViewController(animated: true)
  }
}
