import Foundation
import UIKit
@testable import LOBSTR_Vault

class MnemonicVerificationViewSpy: MnemonicVerificationView {
  func setClearButtonStatus(isEnabled: Bool) {
    
  }
  
  
  var displayShuffledMnemonicListWasCalled = false
  var shuffledCollectionViewWasUpdated = false
  var collectionViewForVerificationWasUpdated = false  
  
  func updateShuffledCollectionView(by indexPath: IndexPath, color: UIColor) {
    shuffledCollectionViewWasUpdated = true
  }
  
  func updateCollectionViewForVerification() {
    collectionViewForVerificationWasUpdated = true
  }
  
  func setShuffledMnemonicList() {
    displayShuffledMnemonicListWasCalled = true
  }
  
  func displayNextButton(isEnabled: Bool) {
    
  }
  
  func displayVerificationError() {
    
  }
  
  func setRightBarButton(isEnabled: Bool) {
    
  }
  
  func setErrorLabel(isHidden: Bool) {
    
  }
  
  func setDashBordersColor(isError: Bool) {
    
  }
  
  func deselectShuffledCollectionView() {
    
  }
  
  func setNextButtonStatus(isEnabled: Bool) {
    
  }
  
}
