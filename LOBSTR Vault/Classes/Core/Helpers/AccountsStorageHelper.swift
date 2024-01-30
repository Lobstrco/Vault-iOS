//

import Foundation
import UIKit

struct AccountsStorageHelper {
  private static let storage: AccountsStorage = AccountsStorageDiskImpl()
  private static var storageAccountsFromLocal: [SignedAccount] = []
  private static var storageAccountsFromCloud: [SignedAccount] = []
  
  static var allSignedAccounts: [SignedAccount] = []
  
  // This key is used to separate nicknames for one account's public key in the iCloud storage
  // while logging by different mnemonics.
  // (We can set different nicknames for one account's public key.)
  static var indicateAddress: String? {
    var indicateAddress: String?
    if let publicKeysFromKeychain = VaultStorage().getPublicKeysFromKeychain() {
      indicateAddress = publicKeysFromKeychain[0]
    } else if let publicKeyFromKeychain = VaultStorage().getPublicKeyFromKeychain() {
      indicateAddress = publicKeyFromKeychain
    }
    return indicateAddress
  }
  
  static func getStoredAccounts() -> [SignedAccount] {
    if let accounts = storage.retrieveAccounts(), !accounts.isEmpty {
      return accounts
    } else if UserDefaultsHelper.isICloudSynchronizationEnabled {
      return CloudKitNicknameHelper.savedAccounts
    } else {
      return []
    }
  }
  
  static func getAllLocalAccounts() -> [SignedAccount] {
    let accounts = storage.retrieveAccounts() ?? []
    let accountsWithNicknames = accounts.filter { !($0.nickname?.isEmpty ?? false)
    }
    return accountsWithNicknames
  }
  
  static func updateIndicateAddress(for accounts: [SignedAccount]) -> [SignedAccount] {
    var updatedAccounts: [SignedAccount] = []
    if !accounts.isEmpty {
      for account in accounts {
        if account.indicateAddress == nil {
          let updatedAccount = SignedAccount(address: account.address, federation: account.federation, nickname: account.nickname, indicateAddress: AccountsStorageHelper.indicateAddress)
          updatedAccounts.append(updatedAccount)
        } else {
          updatedAccounts.append(account)
        }
      }
    }
    return updatedAccounts
  }
  
  static func getMainAccountsFromCache() -> [SignedAccount] {
    var mainAccounts: [SignedAccount] = []
    storageAccountsFromLocal = storage.retrieveAccounts() ?? []
    storageAccountsFromCloud = CloudKitNicknameHelper.savedAccounts
    if let publicKeysFromKeychain = VaultStorage().getPublicKeysFromKeychain() {
      for publicKeyFromKeychain in publicKeysFromKeychain {
        if let account = storageAccountsFromLocal.first(where: { $0.address == publicKeyFromKeychain }) {
          mainAccounts.append(SignedAccount(address: account.address, federation: nil, nickname: account.nickname, indicateAddress: publicKeysFromKeychain[0]))
        } else if UserDefaultsHelper.isICloudSynchronizationEnabled, let account = storageAccountsFromCloud.first(where: { $0.address == publicKeyFromKeychain }) {
          mainAccounts.append(SignedAccount(address: account.address, federation: nil, nickname: account.nickname, indicateAddress: publicKeysFromKeychain[0]))
        } else {
          mainAccounts.append(SignedAccount(address: publicKeyFromKeychain, federation: nil, nickname: "", indicateAddress: publicKeysFromKeychain[0]))
        }
      }
    } else if let publicKeyFromKeychain = VaultStorage().getPublicKeyFromKeychain() {
      if let account = storageAccountsFromLocal.first(where: { $0.address == publicKeyFromKeychain }) {
        mainAccounts.append(SignedAccount(address: account.address, federation: nil, nickname: account.nickname, indicateAddress: publicKeyFromKeychain))
      } else if UserDefaultsHelper.isICloudSynchronizationEnabled, let account = storageAccountsFromCloud.first(where: { $0.address == publicKeyFromKeychain }) {
        mainAccounts.append(SignedAccount(address: account.address, federation: nil, nickname: account.nickname, indicateAddress: publicKeyFromKeychain))
      } else {
        mainAccounts.append(SignedAccount(address: publicKeyFromKeychain, federation: nil, nickname: "", indicateAddress: publicKeyFromKeychain))
      }
    }

    return mainAccounts
  }
  
  static func getActiveAccountNickname() -> String {
    let storageAccounts = getStoredAccounts()
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
  
  static func getAllOtherAccounts() -> [SignedAccount] {
    var otherAccounts = getStoredAccounts()
    var mainAndSignedAccounts: [SignedAccount] = []
    mainAndSignedAccounts.append(contentsOf: getMainAccountsFromCache())
    mainAndSignedAccounts.append(contentsOf: allSignedAccounts)
    
    for account in mainAndSignedAccounts {
      otherAccounts.removeAll(where: { $0.address == account.address })
    }
    
    return otherAccounts
  }
  
  static func updateLocalAccountsFromICloud(isAfterSaveAllToICloud: Bool = false) {
    if isAfterSaveAllToICloud {
      if let localAccounts = storage.retrieveAccounts(), CloudKitNicknameHelper.savedAccounts.count == localAccounts.count {
        saveToLocal()
      }
    } else {
      saveToLocal()
    }
  }
  
  private static func saveToLocal() {
    clear()
    storage.save(accounts: CloudKitNicknameHelper.savedAccounts)
    NotificationCenter.default.post(name: .didActivePublicKeyChange, object: nil)
    NotificationCenter.default.post(name: .didNicknameSet, object: nil)
  }
  
  static func getFromICloudAndUpdateLocalAccounts() {
    CloudKitNicknameHelper.getAllRecords {
      DispatchQueue.main.async {
        updateLocalAccountsFromICloud()
      }
    }
  }
  
  static func saveAllLocalAccountsToICloud() {
    guard UIDevice.isConnectedToNetwork else { return }
    UserDefaultsHelper.isICloudSynchronizationEnabled = true
    let accounts = getStoredAccounts()
    let updatedAccounts = updateIndicateAddress(for: accounts)
    CloudKitNicknameHelper.saveAllToICloud(updatedAccounts)
  }
  
  static func clear() {
    AccountsStorageDiskImpl.clear()
    storageAccountsFromLocal = []
    storageAccountsFromCloud = []
    allSignedAccounts = []
  }
}
