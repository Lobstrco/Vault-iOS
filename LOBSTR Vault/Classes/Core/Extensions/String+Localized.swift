import Foundation

extension String {
  
  func localized() -> String {
    let localizationText = NSLocalizedString(self, comment: "")
    guard !localizationText.isEmpty else {
      return self
    }
    
    return localizationText
  }
  
  var isFederationValid: Bool {
    let federationFormat = ".+\\*[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let federationPredicate = NSPredicate(format: "SELF MATCHES %@", federationFormat)
    if !federationPredicate.evaluate(with: self) {
      return false
    }

    return true
  }

  var isStellarPublicAddress: Bool {
    if !isEmpty, count == 56, let firstLetter = first, firstLetter == "G" {
      return true
    }

    return false
  }
  
  func getTruncatedPublicKey(numberOfCharacters: Int = 8) -> String {
     if self.isStellarPublicAddress {
       return "\(self.prefix(numberOfCharacters))...\(self.suffix(numberOfCharacters))"
     }
     
     return self
   }
}
