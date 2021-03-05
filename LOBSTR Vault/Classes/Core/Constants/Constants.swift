import Foundation

struct Constants {
  static let identiconBaseURL = "https://id.lobstr.co/"
  static let baseLobstrURL = "https://lobstr.co"
  
  static let lobstrScheme = "Lobstr://"
  static let lobstrMultisigScheme = "\(lobstrScheme)multisig"
  
  static let vaultAppleID = "1452248529"
  static let vaultAppStoreLink = "https://itunes.apple.com/app/id\(vaultAppleID)"
  
  static let lobstrAppleID = "1404357892"
  static let lobstrAppStoreLink = "https://itunes.apple.com/app/id\(lobstrAppleID)"
  
  static let appStoreLinkWithReviewAction = "\(vaultAppStoreLink)?action=write-review"
  
  static let vaultMarkerKey = "GA2T6GR7VXXXBETTERSAFETHANSORRYXXXPROTECTEDBYLOBSTRVAULT"
  
  static let recipientEmail = "support@lobstr.co"
  static let subjectEmail = "LOBSTR Vault feedback, \(ApplicationInfo.version)"
  
}
