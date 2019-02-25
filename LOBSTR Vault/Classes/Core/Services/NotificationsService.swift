import Foundation

struct NotificationsService {
  public func registerDeviceForNotifications(with registrationID: String) {
    
    let apiLoader = APIRequestLoader<RegisterDeviceForRemoteNotificationsRequest>(apiRequest: RegisterDeviceForRemoteNotificationsRequest())
    let data = RegisterDeviceForRemoteNotificationsRequestParameters(registrationId: registrationID, active: nil)
    
    apiLoader.loadAPIRequest(requestData: data) { result in
      switch result {
      case .success(_):
        print("SUCCESS REGISTER DEVICE")
      case .failure(let serverRequestError):
        switch serverRequestError {
        case ServerRequestError.needRepeatRequest:
          print("NEED UPDATE TOKEN")
          self.registerDeviceForNotifications(with: registrationID)          
        default:
          print("FAILURE REGISTER DEVICE")
        }
      }
    }
  }
  
  func unregisterDeviceForNotifications(with registrationID: String) {
    let apiLoader = APIRequestLoader<RegisterDeviceForRemoteNotificationsRequest>(apiRequest: RegisterDeviceForRemoteNotificationsRequest())
    let data = RegisterDeviceForRemoteNotificationsRequestParameters(registrationId: registrationID, active: false)
    
    apiLoader.loadAPIRequest(requestData: data) { result in
      switch result {
      case .success(_):
        print("SUCCESS UNREGISTER DEVICE")
      case .failure(let serverRequestError):
        print("FAILURE UNREGISTER DEVICE with error: \(serverRequestError)")
      }
    }
  }
}
