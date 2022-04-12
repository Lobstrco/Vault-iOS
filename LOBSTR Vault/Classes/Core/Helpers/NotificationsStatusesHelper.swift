import Foundation

struct NotificationsStatusesHelper {
  static var isNotificationsEnabled: Bool {
    guard let key = UserDefaultsHelper.pushNotificationsStatuses.keys.first(where: { key in
      key == UserDefaultsHelper.activePublicKey
    }) else { return false }
    guard let isNotificationsEnabled = UserDefaultsHelper.pushNotificationsStatuses[key] else { return false }
    return isNotificationsEnabled
  }
}
