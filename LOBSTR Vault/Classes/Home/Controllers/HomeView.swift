//

import Foundation

protocol HomeView: class {
  func setSections(_ sections: [HomeSection])
  func setTransactionNumber(_ number: String)
  func setPublicKey(_ publicKey: String)
  func setSignerDetails(_ signedAccounts: [SignedAccount])
  
  func setProgressAnimationForTransactionNumber(isEnabled: Bool)
  func setCopyHUD()
}
