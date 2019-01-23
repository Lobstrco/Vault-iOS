import Foundation
import UIKit
@testable import LOBSTR_Vault

class MnemonicVerificationViewSpy: MnemonicVerificationView {
  
  var displayShuffledMnemonicListWasCalled = false
  var shuffledCollectionViewWasUpdated = false
  var collectionViewForVerificationWasUpdated = false  
  
  func updateShuffledCollectionView(by indexPath: IndexPath, color: UIColor) {
    shuffledCollectionViewWasUpdated = true
  }
  
  func updateCollectionViewForVerification() {
    collectionViewForVerificationWasUpdated = true
  }
  
  func displayShuffledMnemonicList() {
    displayShuffledMnemonicListWasCalled = true
  }
  
  func displayNextButton(isEnabled: Bool) {
    
  }
  
  func displayVerificationError() {
    
  }
  
  
}
