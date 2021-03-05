import Foundation
import UIKit

class PinPresenterImpl: PinPresenter {
  var pin: String = ""
  let pinLength = 6
  
  var mode: PinMode
  
  weak var view: PinView?
  
  private let pinManager: PinManager
  private var biometricAuthManager: BiometricAuthManager
  
  private let simplePins = ["123456", "121212", "101010", "112233", "200000", "696969",
                            "131313", "654321", "222111", "111222", "121111", "111112",
                            "011111", "111110", "010000", "000111", "111000", "000001",
                            "100000", "000000", "111111", "222222", "333333", "444444",
                            "555555", "666666", "777777", "888888", "999999"]
  
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
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.biometricAuthManager.authenticateUser { [weak self] result in
          guard let strongSelf = self else { return }
        
          switch result {
          case .success:
            switch strongSelf.mode {
            case .enterPin:
              strongSelf.view?.transitionToHomeScreen()
            case .enterPinForMnemonicPhrase:
              strongSelf.view?.executeCompletion()
            default:
              break
            }
          case .failure:
            break
          }
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
    case .undefined:
      Logger.pin.error("Undefined pin mode")
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
    
    view?.setKeyboardRigthButton(isEnabled: true)
    
    if pin.count == pinLength {
      switch mode {
      case .createPinFirstStep:
        if isSimple(currentPin: pin) {
          self.view?.setSimplePinAlert()
        } else {
          transitionToCreatePinSecondStep(with: .createPinSecondStep(pin))
        }
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
        if isSimple(currentPin: pin) {
          self.view?.setSimplePinAlert()
        } else {
          validateCreatedNewPin()
        }
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
    if pin.count == 1 {
      view?.setKeyboardRigthButton(isEnabled: false)
    }
    
    guard pin.count > 0 else { return }
    pin.removeLast()
    view?.clearPinDot(at: pin.count)
  }
  
  func helpButtonWasPressed() {
    let helpCenter = ZendeskHelper.getHelpCenterController()

    let pinViewController = view as! PinViewController
    pinViewController.navigationController?.pushViewController(helpCenter, animated: true)
  }
  
  func ignoreSimplePin() {
    switch mode {
    case .createPinFirstStep:
      transitionToCreatePinSecondStep(with: .createPinSecondStep(pin))
      break
    case .createNewPinFirstStep:
      validateCreatedNewPin()
      break
    default:
      break
    }
  }
  
  func changeSimplePin() {
    resetPin()
  }
  
  // MARK: - Private
  
  private func isSimple(currentPin: String) -> Bool {
    var isSimple = false
    for pin in simplePins {
      if currentPin == pin {
        isSimple = true
        break
      }
    }
    
    return isSimple
  }
  
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
        view?.transitionToHomeScreen()
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
    let viewControllers = pinViewController.navigationController?.viewControllers
    if let viewControllers = viewControllers {
      for controller in viewControllers {
        if let settingsViewController = controller as? SettingsViewController {
          settingsViewController.showHUDOfSuccessOfChangingPin()
          break
        }
      }
    }
    
    pinViewController.navigationController?.popToRootViewController(animated: true)
  }
}
