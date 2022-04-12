//

import Disk
import Foundation

protocol AccountsStorage {
  func save(accounts: [SignedAccount])
  func retrieveAccounts() -> [SignedAccount]?
}

@objc class AccountsStorageDiskImpl: NSObject, AccountsStorage {
  private let accountsJSONFile = "signers.json"

  func save(accounts: [SignedAccount]) {
    try! Disk.save(accounts, to: .documents, as: accountsJSONFile)
  }

  func retrieveAccounts() -> [SignedAccount]? {
    return try? Disk.retrieve(accountsJSONFile,
                              from: .documents,
                              as: [SignedAccount].self)
  }

  @objc static func clear() {
    try! Disk.clear(.documents)
  }
}
