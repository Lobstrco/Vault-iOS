import Foundation

struct RegisterDeviceForRemoteNotificationsRequestParameters {
  let registrationId: String
  let active: Bool?
}

struct RegisterDeviceForRemoteNotificationsRequest: APIRequest {
  
  func makeRequest(from data: RegisterDeviceForRemoteNotificationsRequestParameters?, jwtToken: String?) throws -> URLRequest {
    let path = "/api/device/"
    let urlString = Environment.baseURL + path
    let url = URL(string: urlString)!
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = APIRequestHTTPMethod.put.rawValue
    
    guard let data = data else {
      throw VaultError.TransactionError.invalidTransaction
    }
    
    var parameters: [String: Any] = ["type": "ios", "registration_id": data.registrationId]
    if let active = data.active {
      parameters["active"] = active
    }
    
    urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
    
    if let token = jwtToken {
      let autrhorizationHeaderField = "Authorization"
      urlRequest.addValue("JWT \(token)", forHTTPHeaderField: autrhorizationHeaderField)
    }
    
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    
    return urlRequest
  }
  
  func parseResponse(data: Data) throws -> RegisterDevice {
    return try JSONDecoder().decode(RegisterDevice.self, from: data)
  }
  
}

struct RegisterDevice: Codable {
  var id: Int?
  var registration_id: String?
  var active: Bool?
  var date_created: String?
  var type: String?
}
