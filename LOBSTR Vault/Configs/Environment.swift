import Foundation

enum Environment {
  private enum Keys {
    static let config = "Config"
    static let baseURL = "BASE_URL"
    static let horizonBaseURL = "HORIZON_BASE_URL"
    static let buildType = "BUILD_TYPE"
    static let environmentType = "ENVIRONMENT_TYPE"
  }
  
  enum Types {
    enum BuildType: String {
      case debug, release, qa
    }
    
    enum EnvironmentType: String {
      case staging, production
    }
  }
  
  static let baseURL: String = {
    guard let baseURLstring = Environment.configDictionary[Keys.baseURL] else {
      fatalError("Base URL not set in plist for this environment")
    }
    
    return baseURLstring
  }()
  
  static let horizonBaseURL: String = {
    guard let horizonBaseURLString = Environment.configDictionary[Keys.horizonBaseURL] else {
      fatalError("Horizon base URL not set in plist for this environment")
    }
    
    return horizonBaseURLString
  }()
  
  static let buildType: Types.BuildType = {
    guard let buildTypeString = Environment.configDictionary[Keys.buildType] else {
      fatalError("Build Type not set in plist for this environment")
    }
    
    guard let type = Types.BuildType.init(rawValue: buildTypeString) else {
      fatalError("Coldn't get build type")
    }
    
    return type
  }()
  
  static let environmentType: Types.EnvironmentType = {
    guard let environmentTypeString = Environment.configDictionary[Keys.environmentType] else {
      fatalError("Environment Type not set in plist for this environment")
    }
    
    guard let type = Types.EnvironmentType.init(rawValue: environmentTypeString) else {
      fatalError("Coldn't get environment type")
    }
    
    return type
  }()
}

// MARK: - Private

private extension Environment {
  static let infoDictionary: [String: Any] = {
    guard let dict = Bundle.main.infoDictionary else {
      fatalError("Plist file wasn't found")
    }
    return dict
  }()
  
  static let configDictionary: [String: String] = {
    guard let config = Environment.infoDictionary[Keys.config] as? [String: String] else {
      fatalError("Config dictionary wasn't found")
    }
    
    return config
  }()
}
