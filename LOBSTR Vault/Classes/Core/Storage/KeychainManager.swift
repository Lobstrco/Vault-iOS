import Foundation

public protocol KeychainManager {
  func store(_ data: Data, with parameters: [String: Any]) -> Bool
  func removeData(with parameters: [String: Any]) -> Bool
  func getData(with parameters: [String: Any]) -> Data?
}

final public class KeychainManagerImpl: KeychainManager {
  public func store(_ data: Data,
                    with parameters: [String: Any]) -> Bool {
    var parameters = parameters
    parameters[kSecValueData as String] = data
    
    let status = SecItemAdd(parameters as CFDictionary, nil)
    guard status == errSecSuccess else {
      print(status)
      if #available(iOS 11.3, *) {
        print(SecCopyErrorMessageString(status, nil) ?? "")
      }
      return false
    }
    
    return true
  }
  
  public func removeData(with parameters: [String : Any]) -> Bool {
    let status = SecItemDelete(parameters as CFDictionary)
    guard status == errSecSuccess else { return false }
    
    return true
  }
  
  public func getData(with parameters: [String: Any]) -> Data? {
    var parameters = parameters
    parameters[kSecReturnData as String] = true
    
    var possibleData: CFTypeRef?
    let status = SecItemCopyMatching(parameters as CFDictionary, &possibleData)
    
    guard let data = possibleData as? Data, status == errSecSuccess else {
      print(status)
      if #available(iOS 11.3, *) {
        print(SecCopyErrorMessageString(status, nil) ?? "")
      }
      return nil
    }
    
    return data
  }
}
