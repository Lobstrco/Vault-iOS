import Foundation

public protocol KeychainManager {
  func store(_ data: Data,
             with parameters: [String: Any]) -> Bool
  func getData(with parameters: [String: Any]) -> Data?
}

public struct KeychainManagerImpl: KeychainManager {
  public func store(_ data: Data,
                    with parameters: [String: Any]) -> Bool {
    var parameters = parameters
    parameters[kSecValueData as String] = data
    
    let status = SecItemAdd(parameters as CFDictionary, nil)
    guard status == errSecSuccess else {
      return false
    }
    
    return true
  }
  
  public func getData(with parameters: [String: Any]) -> Data? {
    var parameters = parameters
    parameters[kSecReturnData as String] = true
    
    var possibleData: CFTypeRef?
    let status = SecItemCopyMatching(parameters as CFDictionary, &possibleData)
    
    guard let data = possibleData as? Data, status == errSecSuccess else {
      return nil
    }
    
    return data
  }
}
