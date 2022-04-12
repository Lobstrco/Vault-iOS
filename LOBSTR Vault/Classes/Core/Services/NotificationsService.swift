import Foundation

struct NotificationsService {
  public func registerDeviceForNotifications(with registrationID: String, with jwtToken: String = "") {
    
    let apiLoader = APIRequestLoader<RegisterDeviceForRemoteNotificationsRequest>(apiRequest: RegisterDeviceForRemoteNotificationsRequest())
    let data = RegisterDeviceForRemoteNotificationsRequestParameters(registrationId: registrationID, active: nil)
    
    apiLoader.loadAPIRequest(requestData: data, jwtToken: jwtToken) { result in
      switch result {
      case .success(_):
        break
      case .failure(let serverRequestError):
        switch serverRequestError {
        case ServerRequestError.needRepeatRequest:
          self.registerDeviceForNotifications(with: registrationID)          
        default:
          // need to create crashlytics event
          break
        }
      }
    }
  }
  
  func unregisterDeviceForNotifications(with registrationID: String, with jwtToken: String = "") {
    let apiLoader = APIRequestLoader<RegisterDeviceForRemoteNotificationsRequest>(apiRequest: RegisterDeviceForRemoteNotificationsRequest())
    let data = RegisterDeviceForRemoteNotificationsRequestParameters(registrationId: registrationID, active: false)
    
    apiLoader.loadAPIRequest(requestData: data, jwtToken: jwtToken) { result in
      switch result {
      case .success(_):
        break
      case .failure:
        break
      }
    }
  }
}
