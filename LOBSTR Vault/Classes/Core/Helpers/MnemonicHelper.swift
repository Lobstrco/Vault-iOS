import Foundation
import stellarsdk

struct MnemonicHelper {
  static func getSeparatedWords(from string: String) -> [String] {
    let components = string.components(separatedBy: .whitespacesAndNewlines)
    
    return components.filter { !$0.isEmpty }
  }
  
  static func getStringFromSeparatedWords(in wordArray: [String]) -> String {
    var string = ""
    
    for (index, word) in wordArray.enumerated() {
      let comma = (index < wordArray.count - 1) ? ", " : ""
      string.append(word + comma)
    }
    
    return string
  }
  
  static func getAutocompleteSuggestions(userText: String) -> [String] {
    var possibleMatches: [String] = []
    let language: WordList = .english
    
    for word in language.englishWords {
      let nsWord: NSString! = word as NSString
      let substringRange: NSRange! = nsWord.range(of: userText)
      
      if substringRange.location == 0 {
        possibleMatches.append(word)
      }
    }
    return possibleMatches.enumerated().compactMap { $0.element }
  }
  
  static func mnemonicWordIsExist(_ word: String) -> Bool {
    let language: WordList = .english
    return language.englishWords.contains(word)
  }
  
  static func addSuggestionWord(to text: String, _ suggestionWord: String) -> String {
    var separatedWords = MnemonicHelper.getSeparatedWords(from: text)
    
    if separatedWords.count > 0 {
      separatedWords.removeLast()
    }
    separatedWords.append(suggestionWord)
    
    var updatedText = separatedWords.joined(separator: " ")
    updatedText.append(" ")
    
    return updatedText
  }
  
  static func getHighlightedAttributedString(attributedString: NSMutableAttributedString,
                                             word: String,
                                             in targetString: String,
                                             highlightColor: UIColor) -> NSMutableAttributedString {
    do {
      let regex = try NSRegularExpression(pattern: word, options: .caseInsensitive)
      let range = NSRange(location: 0, length: targetString.utf16.count)
      for match in regex.matches(in: targetString,
                                 options: .withTransparentBounds,
                                 range: range) {
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                      value: highlightColor,
                                      range: match.range)
      }
      return attributedString
    } catch _ {
      return attributedString
    }
  }
  
  static func getWordMnemonic() -> (mnemonic: String, separatedWords: [String]) {
    let mnemonic = Wallet.generate12WordMnemonic()
    let separetedWords = MnemonicHelper.getSeparatedWords(from: mnemonic)
    
    return (mnemonic: mnemonic, separatedWords: separetedWords)
  }
  
  static func getKeyPairFrom(_ mnemonic: String) -> KeyPair {
    let keyPair = try! Wallet.createKeyPair(mnemonic: mnemonic,
                                            passphrase: nil,
                                            index: 0)
    
    return keyPair
  }
}
