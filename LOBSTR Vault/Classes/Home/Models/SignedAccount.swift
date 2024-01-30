import Foundation
import CloudKit

public struct SignedAccount: Codable {
  var address: String?
  var federation: String?
  var nickname: String?
  
  // This key is used to separate nicknames for one account's public key in the iCloud storage
  // while logging by different mnemonics.
  // (We can set different nicknames for one account's public key.)
  var indicateAddress: String?
  
  var identiconURL: URL {
    let identiconURL = URL(string: "\(Constants.identiconBaseURL)\(address ?? "").png")!
    return identiconURL
  }
  
  static func encode(_ signedAccount: SignedAccount) -> Data? {
    return try? JSONEncoder().encode(signedAccount)
  }
  
  static func decode(_ data: Data) -> SignedAccount? {
    return try? JSONDecoder().decode(SignedAccount.self, from: data)
  }
}

public struct CloudAccount {
  var address: String?
  var federation: String?
  var nickname: String?
  var indicateAddress: String?
  var recordId: CKRecord.ID?
  var modificationDate: Date?
}
