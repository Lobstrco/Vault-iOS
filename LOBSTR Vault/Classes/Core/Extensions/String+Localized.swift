import Foundation

extension String {
  
  func localized() -> String {
    let localizationText = NSLocalizedString(self, comment: "")
    guard !localizationText.isEmpty else {
      return self
    }
    
    return localizationText
  }
}
