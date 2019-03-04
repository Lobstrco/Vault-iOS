import Foundation

struct UserDefaultsHelper {
  
  private static let signerAccountsKey = "numberOfSignerAccounts"
  private static let accountCreatedKey = "isAccountCreated"
  private static let pushNotificationKey = "isPushNotificationsEnabled"
  
  static var isNotificationsEnabled: Bool {
    get { return UserDefaults.standard.bool(forKey: pushNotificationKey) }
    set { UserDefaults.standard.set(newValue, forKey: pushNotificationKey) }
  }
  
  static var numberOfSignerAccounts: Int {
    get { return UserDefaults.standard.integer(forKey: signerAccountsKey) }
    set { UserDefaults.standard.set(newValue, forKey: signerAccountsKey) }
  }
  
  static var accountStatus: AccountStatus {
    get {
      let accountStatusRawValue =  UserDefaults.standard.integer(forKey: accountCreatedKey)
      return AccountStatus(rawValue: accountStatusRawValue) ?? .notCreated
    }
    set { UserDefaults.standard.set(newValue.rawValue, forKey: accountCreatedKey) }
  }
}
