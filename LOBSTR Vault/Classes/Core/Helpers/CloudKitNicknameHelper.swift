//

import CloudKit
import Foundation
import PKHUD

struct CloudKitNicknameHelper {
  private static var identifier = Environment.buildType == .qa ? "" : ""
  
  private static let recordType = "UserNickname"
  
  private static let addressKey = "address"
  private static let federationKey = "federation"
  private static let nicknameKey = "nickname"
  private static let indicateAddressKey = "indicateAddress"
  
  private static let database = CKContainer(identifier: identifier).privateCloudDatabase
  private static let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
  
  static var savedAccounts: [SignedAccount] = []
  private static var cloudAccounts: [CloudAccount] = []
  
  static var accountToSave: SignedAccount?
  
  static var isNeedToShowICloudSyncAdviceAlert: Bool {
    if !UserDefaultsHelper.isICloudSyncAdviceShown,
       !UserDefaultsHelper.isICloudSynchronizationEnabled {
      return true
    } else {
      return false
    }
  }
  
  private static var accountsToSaveToICloudCount = 0
  private static var savedRecordsToICloudCount = 0
  private static var duplicatesAccountToRemoveFromICloudCount = 0
  private static var removedRecordsFromICloudCount = 0
  
  static func checkIsICloudStatusAvaliable(completion: @escaping (Bool) -> Void) {
    CKContainer.default().accountStatus { accountStatus, _ in
      if accountStatus == .available {
        completion(true)
      } else {
        completion(false)
      }
    }
  }
  
  static func getAllRecords(completion: (() -> Void)? = nil) {
    guard UIDevice.isConnectedToNetwork else { return }
    checkIsICloudStatusAvaliable { isAvaliable in
      if isAvaliable {
        UserDefaultsHelper.isICloudSynchronizationActive = false
        database.perform(query, inZoneWith: nil) { records, error in
          if let records = records, error == nil {
            clear()
            cloudAccounts = records.compactMap { record in
              if let indicateAddress = record.object(forKey: indicateAddressKey) as? String,
                 indicateAddress == AccountsStorageHelper.indicateAddress
              {
                return CloudAccount(address: record.object(forKey: addressKey) as? String,
                                    federation: record.object(forKey: federationKey) as? String,
                                    nickname: record.object(forKey: nicknameKey) as? String,
                                    indicateAddress: indicateAddress,
                                    recordId: record.recordID,
                                    modificationDate: record.modificationDate)
              } else {
                return nil
              }
            }

            // Sort cloudAccounts by modified date
            let sortedCloudAccounts = cloudAccounts.sorted(by: { $0.modificationDate?.compare($1.modificationDate!) == .orderedDescending })
            
            // Find duplicate accounts
            var seenPublicKeys = [String]()
            var duplicateAccounts = [CloudAccount]()
            
            for account in sortedCloudAccounts {
              if let publicKey = account.address {
                if seenPublicKeys.contains(publicKey) {
                  duplicateAccounts.append(account)
                } else {
                  seenPublicKeys.append(publicKey)
                }
              }
            }
            
            if !duplicateAccounts.isEmpty {
              // Remove duplicate accounts from iCloud
              removeFromICloud(cloudAccounts: duplicateAccounts) {
                getAllRecords()
              }
            } else {
              savedAccounts = cloudAccounts.compactMap { account in
                SignedAccount(address: account.address, federation: account.federation, nickname: account.nickname, indicateAddress: account.indicateAddress)
              }
              completion?()
              NotificationCenter.default.post(name: .didCloudRecordsGet, object: nil)
            }
          } else {
            completion?()
            NotificationCenter.default.post(name: .didCloudRecordsGetError, object: nil)
          }
        }
      } else if UserDefaultsHelper.isICloudSynchronizationEnabled {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
          NotificationCenter.default.post(name: .iCloudStatusIsNotAvaliable, object: nil)
        }
      }
    }
  }
  
  static func isICloudDatabaseEmpty(completion: ((Bool) -> Void)?) {
    guard UIDevice.isConnectedToNetwork else { return }
    database.perform(query, inZoneWith: nil) { records, error in
      if let records = records, error == nil {
        let cloudAccounts = records.compactMap { record in
          if let indicateAddress = record.object(forKey: indicateAddressKey) as? String,
             indicateAddress == AccountsStorageHelper.indicateAddress
          {
            return CloudAccount(address: record.object(forKey: addressKey) as? String,
                                federation: record.object(forKey: federationKey) as? String,
                                nickname: record.object(forKey: nicknameKey) as? String,
                                indicateAddress: indicateAddress,
                                recordId: record.recordID,
                                modificationDate: record.modificationDate)
          } else {
            return nil
          }
        }
        completion?(cloudAccounts.isEmpty)
      } else {
        completion?(false)
      }
    }
  }
    
  static func saveAllToICloud(_ signedAccounts: [SignedAccount]) {
    guard UserDefaultsHelper.isICloudSynchronizationEnabled else { return }
    accountsToSaveToICloudCount = signedAccounts.count
    UserDefaultsHelper.isICloudSynchronizationActive = true
    for signedAccount in signedAccounts {
      saveToICloud(signedAccount)
    }
  }
    
  static func saveToICloud(_ signedAccount: SignedAccount) {
    guard UserDefaultsHelper.isICloudSynchronizationEnabled,
          UIDevice.isConnectedToNetwork
    else {
      UserDefaultsHelper.isICloudSynchronizationActive = false
      return
    }
    checkIsICloudStatusAvaliable { isAvaliable in
      if isAvaliable {
        if savedAccounts.first(where: { $0.address == signedAccount.address }) != nil {
          updateRecord(signedAccount)
        } else {
          addNewRecord(signedAccount) {
            // We need to get all the data from the iCloud after saving all local accounts to the iCloud
            retryGetAllRecords()
          }
        }
      } else {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
          UserDefaultsHelper.isICloudSynchronizationActive = false
          NotificationCenter.default.post(name: .iCloudStatusIsNotAvaliable, object: nil)
        }
      }
    }
  }
  
  static func clear() {
    savedAccounts = []
    cloudAccounts = []
  }
  
  static func finishSynchronization() {
    clearLocalVariables()
    UserDefaultsHelper.isICloudSynchronizationActive = false
  }
  
  static func isAllRecordsReceived(completion: @escaping (Bool) -> Void) {
    database.perform(query, inZoneWith: nil) { records, error in
      if let records = records, error == nil {
        if records.count == accountsToSaveToICloudCount {
          completion(true)
        } else {
          completion(false)
        }
      } else {
        UserDefaultsHelper.isICloudSynchronizationActive = false
        completion(false)
      }
    }
  }
    
  // MARK: - Private
  
  private static func retryGetAllRecords() {
    MyTimer.startTimer()
  }
  
  private static func removeFromICloud(cloudAccounts: [CloudAccount], completion: (() -> Void)? = nil) {
    duplicatesAccountToRemoveFromICloudCount = cloudAccounts.count
    for cloudAccount in cloudAccounts {
      deleteRecord(cloudAccount) {
        completion?()
      }
    }
  }
  
  private static func deleteRecord(_ cloudAccount: CloudAccount, completion: (() -> Void)? = nil) {
    guard let recordId = cloudAccount.recordId else { return }
    database.delete(withRecordID: recordId) { record, error in
      guard record != nil, error == nil else { return }
      
      removedRecordsFromICloudCount += 1
      
      if removedRecordsFromICloudCount == duplicatesAccountToRemoveFromICloudCount {
        removedRecordsFromICloudCount = 0
        completion?()
      }
    }
  }

  private static func clearLocalVariables() {
    accountsToSaveToICloudCount = 0
    savedRecordsToICloudCount = 0
    duplicatesAccountToRemoveFromICloudCount = 0
    removedRecordsFromICloudCount = 0
  }
    
  private static func addNewRecord(_ signedAccount: SignedAccount, completion: (() -> Void)? = nil) {
    let record = CKRecord(recordType: recordType)
    var keyedValues: [String: String] = [:]
    keyedValues[addressKey] = signedAccount.address
    keyedValues[federationKey] = signedAccount.federation
    keyedValues[nicknameKey] = signedAccount.nickname
    keyedValues[indicateAddressKey] = signedAccount.indicateAddress
    record.setValuesForKeys(keyedValues)
    database.save(record) { record, error in
      guard record != nil, error == nil else {
        UserDefaultsHelper.isICloudSynchronizationActive = false
        return
      }
      let cloudAccount = CloudAccount(address: record?.object(forKey: addressKey) as? String,
                                      federation: record?.object(forKey: federationKey) as? String,
                                      nickname: record?.object(forKey: nicknameKey) as? String,
                                      indicateAddress: signedAccount.indicateAddress,
                                      recordId: record?.recordID)
      
      let savedAccount = SignedAccount(address: cloudAccount.address,
                                       federation: cloudAccount.federation,
                                       nickname: cloudAccount.nickname,
                                       indicateAddress: cloudAccount.indicateAddress)
      cloudAccounts.append(cloudAccount)
      savedAccounts.append(savedAccount)
      
      savedRecordsToICloudCount += 1
      
      if savedRecordsToICloudCount == accountsToSaveToICloudCount {
        savedRecordsToICloudCount = 0
        completion?()
      }
    }
  }
    
  private static func updateRecord(_ signedAccount: SignedAccount) {
    if let cloudAccount = cloudAccounts.first(where: { $0.address == signedAccount.address }),
       let recordID = cloudAccount.recordId
    {
      database.fetch(withRecordID: recordID) { record, error in
        if let record = record, error == nil {
          var keyedValues: [String: String] = [:]
          keyedValues[addressKey] = signedAccount.address
          keyedValues[federationKey] = signedAccount.federation
          keyedValues[nicknameKey] = signedAccount.nickname
          keyedValues[indicateAddressKey] = signedAccount.indicateAddress
          record.setValuesForKeys(keyedValues)
          database.save(record) { record, error in
            guard record != nil, error == nil else { return }
          }
        }
      }
    }
  }
}

class MyTimer: NSObject {
  static var timer: Timer?
  
  static func startTimer() {
    DispatchQueue.main.async {
      if timer == nil {
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.getRecords), userInfo: nil, repeats: true)
      }
    }
  }
  
  @objc static func getRecords() {
    CloudKitNicknameHelper.isAllRecordsReceived { result in
      if result {
        timer?.invalidate()
        timer = nil
        CloudKitNicknameHelper.finishSynchronization()
      }
    }
  }
}
