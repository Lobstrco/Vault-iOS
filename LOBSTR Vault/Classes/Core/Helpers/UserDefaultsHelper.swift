import Foundation

@propertyWrapper
struct UserDefault<T> {
  private let key: String
  private let defaultValue: T
  private let userDefaults: UserDefaults

  init(_ key: String, defaultValue: T, userDefaults: UserDefaults = .standard) {
    self.key = key
    self.defaultValue = defaultValue
    self.userDefaults = userDefaults
  }

  var wrappedValue: T {
    get {
      guard let value = userDefaults.object(forKey: key) else {
        return defaultValue
      }

      return value as? T ?? defaultValue
    }
    set {
      if let value = newValue as? OptionalProtocol, value.isNil() {
        userDefaults.removeObject(forKey: key)
      } else {
        userDefaults.set(newValue, forKey: key)
      }
    }
  }
}

private protocol OptionalProtocol {
  func isNil() -> Bool
}

extension Optional: OptionalProtocol {
  func isNil() -> Bool {
    return self == nil
  }
}

enum UserDefaultsHelper {
  private static let signerAccountsKey = "numberOfSignerAccounts"
  private static let accountCreatedKey = "isAccountCreated"
  private static let pushNotificationKey = "isPushNotificationsEnabled"
  private static let promtForTransactionDecisionsKey = "isPromtTransactionDecisionsEnabled"
  
  private static let tangemCardIdKey = "tangemCardId"
  private static let tangemPublicKeyDataKey = "tangemPublicKeyData"
  
  private static let appLaunchesCounterKey = "appLaunchesCounter"
  private static let appLaunchesCounterEnabledKey = "appLaunchesCounterEnabled"

  static let showUpdateAdviceKey = "showUpdateAdvice"
  
  private static let afterLoginKey = "isAfterLogin"
  
  private static let badgesCounterKey = "badgesCounter"
  
  private static let activePublicAddressKey = "activePublicAddress"
  private static let activePublicAddressIndexKey = "activePublicAddressIndex"
  private static let pushNotificationsStatusesKey = "pushNotificationsStatuses"
  private static let promtForTransactionDecisionsStatusesKey = "promtForTransactionDecisionsStatuses"
  
  private static let iCloudSynchronizationKey = "iCloudSynchronization"
  private static let showICloudSyncAdviceKey = "showICloudSyncAdvice"
  
  private static let actualTransactionNumberKey = "actualTransactionNumber"

  private static let iCloudSynchronizationActiveKey = "isICloudSynchronizationActive"
  
  @UserDefault(pushNotificationKey, defaultValue: true)
  static var isNotificationsEnabled: Bool
    
  @UserDefault(promtForTransactionDecisionsKey, defaultValue: true)
  static var isPromtTransactionDecisionsEnabled: Bool
  
  @UserDefault(signerAccountsKey, defaultValue: 0)
  static var numberOfSignerAccounts: Int
    
  @UserDefault(tangemCardIdKey, defaultValue: nil)
  static var tangemCardId: String?
  
  @UserDefault(tangemPublicKeyDataKey, defaultValue: nil)
  static var tangemPublicKeyData: Data?
  
  @UserDefault(appLaunchesCounterKey, defaultValue: 0)
  static var appLaunchesCounter: Int
  
  @UserDefault(appLaunchesCounterEnabledKey, defaultValue: false)
  static var isAppLaunchesCounterEnabled: Bool
  
  @UserDefault(afterLoginKey, defaultValue: false)
  static var isAfterLogin: Bool
  
  @UserDefault(badgesCounterKey, defaultValue: 0)
  static var badgesCounter: Int
  
  @UserDefault(activePublicAddressKey, defaultValue: "")
  static var activePublicKey: String
  
  @UserDefault(activePublicAddressIndexKey, defaultValue: 0)
  static var activePublicKeyIndex: Int
  
  @UserDefault(pushNotificationsStatusesKey, defaultValue: [:])
  static var pushNotificationsStatuses: [String:Bool]
  
  @UserDefault(promtForTransactionDecisionsStatusesKey, defaultValue: [:])
  static var promtForTransactionDecisionsStatuses: [String:Bool]
  
  @UserDefault(iCloudSynchronizationKey, defaultValue: false)
  static var isICloudSynchronizationEnabled: Bool
  
  @UserDefault(showICloudSyncAdviceKey, defaultValue: false)
  static var isICloudSyncAdviceShown
    
  @UserDefault(actualTransactionNumberKey, defaultValue: 0)
  static var actualTransactionNumber: Int
  
  @UserDefault(iCloudSynchronizationActiveKey, defaultValue: false)
  static var isICloudSynchronizationActive
  
  static var accountStatus: AccountStatus {
    get {
      let accountStatusRawValue = UserDefaults.standard.integer(forKey: accountCreatedKey)
      return AccountStatus(rawValue: accountStatusRawValue) ?? .notCreated
    }
    set { UserDefaults.standard.set(newValue.rawValue, forKey: accountCreatedKey) }
  }
}
