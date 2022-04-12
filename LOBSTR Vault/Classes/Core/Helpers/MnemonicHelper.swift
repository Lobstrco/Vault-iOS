import Foundation
import stellarsdk

struct MnemonicHelper {
  
  static let additionalAccountsCountLimit = 4
  
  private static let sdk = stellarsdk.StellarSDK(withHorizonUrl: Environment.horizonBaseURL)
  
  static func getSeparatedWords(from string: String) -> [String] {
    let components = string.components(separatedBy: .whitespacesAndNewlines)
    
    return components.filter { !$0.isEmpty }
  }
  
  static func getStringFromSeparatedWords(in wordArray: [String]) -> String {
    var string = ""
    
    for (index, word) in wordArray.enumerated() {
      let space = (index < wordArray.count - 1) ? " " : ""
      string.append(word + space)
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
      let regex = try NSRegularExpression(pattern: word + " ", options: .caseInsensitive)
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
  
  static func getKeyPairFrom(_ mnemonic: String, index: Int = 0) -> KeyPair {
    let keyPair = try! Wallet.createKeyPair(mnemonic: mnemonic,
                                            passphrase: nil,
                                            index: index)
    
    return keyPair
  }
  
  static func encryptAndStoreInKeychain(mnemonic: String,
                                        recoveryIndex: Int = 0,
                                        mnemonicManager: MnemonicManager = MnemonicManagerImpl(),
                                        vaultStorage: VaultStorage = VaultStorage()) {
    guard mnemonicManager.encryptAndStoreInKeychain(mnemonic: mnemonic) else {
      fatalError()
    }
    
    var publicKeys: [String] = []
    for index in 0...recoveryIndex {
      let keyPair = MnemonicHelper.getKeyPairFrom(mnemonic, index: index)
      publicKeys.append(keyPair.accountId)
    }
    
    vaultStorage.storePublicKeysInKeychain(publicKeys)
    if let publicKey = publicKeys.first {
      vaultStorage.storeActivePublicKeyInKeychain(publicKey)
      UserDefaultsHelper.activePublicKey = publicKey
      UserDefaultsHelper.activePublicKeyIndex = 0
    }
  }
  
  static func getRecoveryIndex(mnemonic: String, completion: @escaping (Int) -> Void) {
    var allPublicKeys: [String] = []
    var recoveyIndex = 0
    var verifiedIndex = 0
    
    for index in 0...additionalAccountsCountLimit {
      let keyPair = MnemonicHelper.getKeyPairFrom(mnemonic, index: index)
      allPublicKeys.append(keyPair.accountId)
    }
    
    let dispatchQueue = DispatchQueue(label: "myQueue", qos: .background)
    
    dispatchQueue.async {
      for index in (1...additionalAccountsCountLimit).reversed() {
        isSigner(publicKey: allPublicKeys[index]) { result in
          verifiedIndex = index
          if result == true {
            recoveyIndex = index
            completion(recoveyIndex)
          } else if verifiedIndex == 1 {
            completion(recoveyIndex)
          }
        }
      }
    }
  }
  
  static func isSigner(publicKey: String, completion: @escaping (Bool) -> Void) {
    let semaphore = DispatchSemaphore(value: 0)
    sdk.accounts.getAccounts(signer: publicKey) { result in
      switch result {
      case .success(let details):
        if let record = details.records.first, !record.signers.isEmpty {
          completion(true)
        } else {
          semaphore.signal()
          completion(false)
        }
      case .failure:
        semaphore.signal()
        completion(false)
      }
    }
    // Wait until the previous API request completes
    semaphore.wait()
  }
}
