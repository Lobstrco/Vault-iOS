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
  
  let pinManager: PinManager
  
  let navigationController: UINavigationController
  
  // MARK: - Init
  
  init(view: PinView,
       navigationController: UINavigationController,
       mode: PinMode,
       pinManager: PinManager = PinManagerImpl()) {
    self.view = view
    self.mode = mode
    self.navigationController = navigationController
    self.pinManager = pinManager
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
        
        guard pinManager.validate(pinFromFirstStep, pin), pinManager.store(pin)
        else {
          view?.shakePinView()
          return
        }
        
        updateToken()
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
  
  // MARK: - Private Methods
  
  private func updateToken() {
    AuthenticationService().updateToken() { result in
      switch result {
      case .success(_):
        self.transitionToHomeScreen()
      case .failure(let error):
        print("Couldn't get token. \(error)")
      }
    }
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
