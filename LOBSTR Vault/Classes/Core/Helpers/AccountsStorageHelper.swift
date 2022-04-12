//

import Foundation

struct AccountsStorageHelper {
  
  private static let storage: AccountsStorage = AccountsStorageDiskImpl()
  private static var storageAccounts: [SignedAccount] = []
  
  static var allSignedAccounts: [SignedAccount] = []
  
  static func getMainAccountsFromCache() -> [SignedAccount] {
    var mainAccounts: [SignedAccount] = []
    storageAccounts = storage.retrieveAccounts() ?? []
    if let publicKeysFromKeychain = VaultStorage().getPublicKeysFromKeychain() {
      for publicKeyFromKeychain in publicKeysFromKeychain {
        if let account = storageAccounts.first(where: { $0.address == publicKeyFromKeychain }) {
          mainAccounts.append(SignedAccount(address: account.address, federation: nil, nickname: account.nickname))
        } else {
          mainAccounts.append(SignedAccount(address: publicKeyFromKeychain, federation: nil, nickname: ""))
        }
      }
    } else if let publicKeyFromKeychain = VaultStorage().getPublicKeyFromKeychain() {
      if let account = storageAccounts.first(where: { $0.address == publicKeyFromKeychain }) {
        mainAccounts.append(SignedAccount(address: account.address, federation: nil, nickname: account.nickname))
      } else {
        mainAccounts.append(SignedAccount(address: publicKeyFromKeychain, federation: nil, nickname: ""))
      }
    }

    return mainAccounts
  }
  
  static func getActiveAccountNickname() -> String {
    storageAccounts = storage.retrieveAccounts() ?? []
    let nickname = storageAccounts.first { $0.address == UserDefaultsHelper.activePublicKey }?.nickname ?? ""
    return nickname
  }
  
  static func updateAllSignedAccounts(signedAccounts: [SignedAccount]) {
    if allSignedAccounts.isEmpty {
      allSignedAccounts.append(contentsOf: signedAccounts)
    } else {
      for signedAccount in signedAccounts {
        if let index = allSignedAccounts.firstIndex(where: { $0.address == signedAccount.address }) {
          allSignedAccounts[index] = signedAccount
        } else {
          allSignedAccounts.append(signedAccount)
        }
      }
    }
  }
}
