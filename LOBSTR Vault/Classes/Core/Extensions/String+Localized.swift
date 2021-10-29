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
  
  var isShortStellarPublicAddress: Bool {
    if !isEmpty, let firstLetter = first, firstLetter == "G", self.contains("...") {
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
  
  func getMiddleTruncated(numberOfCharacters: Int = 8) -> String {
    return "\(self.prefix(numberOfCharacters))...\(self.suffix(numberOfCharacters))"
  }
  
  func split(by length: Int) -> [String] {
    var startIndex = self.startIndex
    var results = [Substring]()
    
    while startIndex < self.endIndex {
      let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
      results.append(self[startIndex..<endIndex])
      startIndex = endIndex
    }
    
    return results.map { String($0) }
  }
}

extension StringProtocol where Self: RangeReplaceableCollection {
    mutating func insert<S: StringProtocol>(separator: S, every n: Int) {
        for index in indices.every(n: n).dropFirst().reversed() {
            insert(contentsOf: separator, at: index)
        }
    }
    func inserting<S: StringProtocol>(separator: S, every n: Int) -> Self {
        .init(unfoldSubSequences(limitedTo: n).joined(separator: separator))
    }
}
