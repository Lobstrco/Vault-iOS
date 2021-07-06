//

import Foundation
import Disk

protocol SignersStorage {
  func save(signers: [SignedAccount])
  func retrieveSigners() -> [SignedAccount]?
}

@objc class SignersStorageDiskImpl: NSObject, SignersStorage {
  
  private let signersJSONFile = "signers.json"
  
  func save(signers: [SignedAccount]) {
    try! Disk.save(signers, to: .documents, as: signersJSONFile)
  }
  
  func retrieveSigners() -> [SignedAccount]? {
    return try? Disk.retrieve(signersJSONFile,
                              from: .documents,
                              as: [SignedAccount].self)
  }
  
  @objc static func clear() {
    try! Disk.clear(.documents)
  }
}
