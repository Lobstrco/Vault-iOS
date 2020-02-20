import Foundation
import stellarsdk

class GettingMnemonicOperation: AsyncOperation {
  
  var outputKeyPair: KeyPair?
  
  override func main() {
    let mnemonicManager = MnemonicManagerImpl()
    
    guard mnemonicManager.isMnemonicStoredInKeychain() else {
      return
    }
    
    mnemonicManager.getDecryptedMnemonicFromKeychain { result in
      switch result {
      case .success(let mnemonic):
        self.outputKeyPair = MnemonicHelper.getKeyPairFrom(mnemonic)
        self.finished(error: nil)
      case .failure(let error):
        self.finished(error: error)        
      }
    }
  }
}

extension GettingMnemonicOperation: KeyPairBroadcast {
  var keyPair: KeyPair? { return outputKeyPair }
  var error: Error? { return outputError }
}
