import Foundation

public enum PinMode {
  case createPinFirstStep
  case createPinSecondStep(String)
  case enterPin
  case changePin
  case createNewPinFirstStep
  case createNewPinSecondStep(String)
  case undefined
}
