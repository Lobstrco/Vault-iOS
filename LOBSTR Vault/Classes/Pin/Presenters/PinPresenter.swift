import Foundation
import UIKit

enum PinMode {
  case createPinFirstStep
  case createPinSecondStep(String)
  case enterPin
  case undefined
}

protocol PinPresenter: class {
  func pinViewDidLoad()
  func digitButtonWasPressed(with digit: Int)
  func removeButtonWasPressed()
}

class PinPresenterImpl: PinPresenter {
  var pin: String = ""
  let pinLength = 6
  
  var mode: PinMode
  
  weak var view: PinView?
  
  let pinManager = PinManagerImpl()
  let navigationController: UINavigationController
  
  // MARK: - Init
  
  init(view: PinView,
       navigationController: UINavigationController,
       mode: PinMode) {
    self.view = view
    self.mode = mode
    self.navigationController = navigationController
  }
  
  // MARK: - PinPresenter
  
  func pinViewDidLoad() {
    switch mode {
    case .createPinFirstStep:
      view?.showTitle("Create Pin")
    case .createPinSecondStep:
      view?.showTitle("Confirm Pin")
    default:
      break
    }
  }
  
  func digitButtonWasPressed(with digit: Int) {
    guard pin.count < pinLength else { return }
    view?.fillPinDot(at: pin.count)
    pin += String(digit)
    
    switch mode {
    case .createPinFirstStep:
      
      if pin.count == pinLength {
        transitionToCreatePinSecondStep()
      }
      
    case .createPinSecondStep(let pinFromFirstStep):
      
      if pin.count == pinLength {
        
        if pinManager.validate(pinFromFirstStep, pin) == true {
          if pinManager.store(pin) == true {
            transitionToHomeScreen()
          }
        } else {
          view?.shakePinView()
        }
        
      }
      
    case .enterPin:
      if pin.count == pinLength {
        guard let storedPin = pinManager.getPin() else { return }
        
        if pinManager.validate(storedPin, pin) == true {
          transitionToHomeScreen()
        } else {
          view?.shakePinView()
        }
        
      }
      
    case .undefined:
      fatalError()
    }
  }
  
  func removeButtonWasPressed() {
    guard pin.count > 0 else { return }
    pin.removeLast()
    view?.clearPinDot(at: pin.count)
  }
  
  // MARK: - Navigation
  
  func transitionToCreatePinSecondStep() {
    guard let pinViewController = PinViewController.createFromStoryboard()
    else { return }
    
    pinViewController.mode = .createPinSecondStep(pin)
    
    navigationController.pushViewController(pinViewController,
                                            animated: true)
  }
  
  func transitionToHomeScreen() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
    else { return }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      appDelegate.applicationCoordinator.showHomeScreen()
    }
    
  }
}
