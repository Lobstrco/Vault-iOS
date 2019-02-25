import Foundation
import UIKit

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
    case .enterPin, .enterPinForMnemonicPhrase:
      
      switch mode {
      case .enterPinForMnemonicPhrase:
        view?.setCancelBarButtonItem()
      default: break
      }
      
      guard biometricAuthManager.isBiometricAuthEnabled else { return }
      
      biometricAuthManager.authenticateUser { [weak self] result in
        guard let strongSelf = self else { return }
        
        switch result {
        case .success:
          switch strongSelf.mode {
          case .enterPin:
            strongSelf.transitionToHomeScreen()
          case .enterPinForMnemonicPhrase:
            strongSelf.view?.executeCompletion()
          default:
            break
          }
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
  
  func pinViewWillAppear() {
    resetPin()
    view?.show(error: "")
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
          view?.show(error: L10n.textChangePasscodeError)
          resetPin()
          shakePin()
        }
      case .enterPin, .enterPinForMnemonicPhrase:
        validateEnteredPin(mode: mode)
      case .changePin:
        validateChangedPin()
      case .createNewPinFirstStep:
        validateCreatedNewPin()
      case .createNewPinSecondStep(let pinFromFirstStep):
        if pinManager.validate(pinFromFirstStep, pin), pinManager.store(pin) {
          transitionToSettings()
        } else {
          view?.show(error: L10n.textChangePasscodeError)
          resetPin()
          shakePin()
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
  
  private func resetPin() {
    pin.removeAll()
    view?.clearPinDots()
  }
  
  private func shakePin() {
    view?.shakePinView()
  }
  
  private func validateEnteredPin(mode: PinMode) {
    guard let storedPin = pinManager.getPin() else { return }
    
    if pinManager.validate(storedPin, pin) == true {
      switch mode {
      case .enterPin:
        transitionToHomeScreen()
      case .enterPinForMnemonicPhrase:
        view?.executeCompletion()
      default:
        return
      }
      
    } else {
      resetPin()
      shakePin()
    }
  }
  
  private func validateCreatedNewPin() {
    guard let storedPin = pinManager.getPin() else { return }
    
    if storedPin == pin {
      resetPin()
      shakePin()
      view?.show(error: L10n.textChangeTheSamePasscode)
    } else {
      transitionToCreatePinSecondStep(with: .createNewPinSecondStep(pin))
    }
  }
  
  private func validateChangedPin() {
    guard let storedPin = pinManager.getPin() else { return }
    
    if pinManager.validate(storedPin, pin) == true {
      transitionToCreatePinFirstStep(with: .createNewPinFirstStep)
    } else {
      resetPin()
      shakePin()
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
