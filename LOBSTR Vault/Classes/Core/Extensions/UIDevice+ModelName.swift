import UIKit

public extension UIDevice {
  static let modelName: String = {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }

    func mapToDevice(identifier: String) -> String {
      #if os(iOS)
      switch identifier {
      case "iPod5,1":
        return "iPod touch (5th generation)"
      case "iPod7,1":
        return "iPod touch (6th generation)"
      case "iPod9,1":
        return "iPod touch (7th generation)"
      case "iPhone3,1", "iPhone3,2", "iPhone3,3":
        return "iPhone 4"
      case "iPhone4,1":
        return "iPhone 4s"
      case "iPhone5,1", "iPhone5,2":
        return "iPhone 5"
      case "iPhone5,3", "iPhone5,4":
        return "iPhone 5c"
      case "iPhone6,1", "iPhone6,2":
        return "iPhone 5s"
      case "iPhone7,2":
        return "iPhone 6"
      case "iPhone7,1":
        return "iPhone 6 Plus"
      case "iPhone8,1":
        return "iPhone 6s"
      case "iPhone8,2":
        return "iPhone 6s Plus"
      case "iPhone8,4":
        return "iPhone SE"
      case "iPhone9,1", "iPhone9,3":
        return "iPhone 7"
      case "iPhone9,2", "iPhone9,4":
        return "iPhone 7 Plus"
      case "iPhone10,1", "iPhone10,4":
        return "iPhone 8"
      case "iPhone10,2", "iPhone10,5":
        return "iPhone 8 Plus"
      case "iPhone10,3", "iPhone10,6":
        return "iPhone X"
      case "iPhone11,2":
        return "iPhone XS"
      case "iPhone11,4", "iPhone11,6":
        return "iPhone XS Max"
      case "iPhone11,8":
        return "iPhone XR"
      case "iPhone12,1":
        return "iPhone 11"
      case "iPhone12,3":
        return "iPhone 11 Pro"
      case "iPhone12,5":
        return "iPhone 11 Pro Max"
      case "iPhone12,8":
        return "iPhone SE (2nd generation)"
      case "iPhone13,1":
        return "iPhone 12 mini"
      case "iPhone13,2":
        return "iPhone 12"
      case "iPhone13,3":
        return "iPhone 12 Pro"
      case "iPhone13,4":
        return "iPhone 12 Pro Max"
      case "iPhone14,4":
        return "iPhone 13 mini"
      case "iPhone14,5":
        return "iPhone 13"
      case "iPhone14,2":
        return "iPhone 13 Pro"
      case "iPhone14,3":
        return "iPhone 13 Pro Max"
      case "iPhone14,6":
        return "iPhone SE (3rd generation)"
      case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
        return "iPad 2"
      case "iPad3,1", "iPad3,2", "iPad3,3":
        return "iPad (3rd generation)"
      case "iPad3,4", "iPad3,5", "iPad3,6":
        return "iPad (4th generation)"
      case "iPad6,11", "iPad6,12":
        return "iPad (5th generation)"
      case "iPad7,5", "iPad7,6":
        return "iPad (6th generation)"
      case "iPad7,11", "iPad7,12":
        return "iPad (7th generation)"
      case "iPad11,6", "iPad11,7":
        return "iPad (8th generation)"
      case "iPad4,1", "iPad4,2", "iPad4,3":
        return "iPad Air"
      case "iPad5,3", "iPad5,4":
        return "iPad Air 2"
      case "iPad11,3", "iPad11,4":
        return "iPad Air (3rd generation)"
      case "iPad13,1", "iPad13,2":
        return "iPad Air (4th generation)"
      case "iPad2,5", "iPad2,6", "iPad2,7":
        return "iPad mini"
      case "iPad4,4", "iPad4,5", "iPad4,6":
        return "iPad mini 2"
      case "iPad4,7", "iPad4,8", "iPad4,9":
        return "iPad mini 3"
      case "iPad5,1", "iPad5,2":
        return "iPad mini 4"
      case "iPad11,1", "iPad11,2":
        return "iPad mini (5th generation)"
      case "iPad6,3", "iPad6,4":
        return "iPad Pro (9.7-inch)"
      case "iPad7,3", "iPad7,4":
        return "iPad Pro (10.5-inch)"
      case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":
        return "iPad Pro (11-inch) (1st generation)"
      case "iPad8,9", "iPad8,10":
        return "iPad Pro (11-inch) (2nd generation)"
      case "iPad6,7", "iPad6,8":
        return "iPad Pro (12.9-inch) (1st generation)"
      case "iPad7,1", "iPad7,2":
        return "iPad Pro (12.9-inch) (2nd generation)"
      case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":
        return "iPad Pro (12.9-inch) (3rd generation)"
      case "iPad8,11", "iPad8,12":
        return "iPad Pro (12.9-inch) (4th generation)"
      case "AppleTV5,3":
        return "Apple TV"
      case "AppleTV6,2":
        return "Apple TV 4K"
      case "AudioAccessory1,1":
        return "HomePod"
      case "i386", "x86_64":
        return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
      default:
        return identifier
      }
      #elseif os(tvOS)
      switch identifier {
      case "AppleTV5,3":
        return "Apple TV 4"
      case "AppleTV6,2":
        return "Apple TV 4K"
      case "i386", "x86_64":
        return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
      default: return identifier
      }
      #endif
    }

    return mapToDevice(identifier: identifier)
  }()
}

public enum Model: String {
  // Simulator
  case simulator = "simulator/sandbox",

       // iPod
       iPod1 = "iPod 1",
       iPod2 = "iPod 2",
       iPod3 = "iPod 3",
       iPod4 = "iPod 4",
       iPod5 = "iPod 5",
       iPod6 = "iPod 6",
       iPod7 = "iPod 7",

       // iPad
       iPad2 = "iPad 2",
       iPad3 = "iPad 3",
       iPad4 = "iPad 4",
       iPadAir = "iPad Air ",
       iPadAir2 = "iPad Air 2",
       iPadAir3 = "iPad Air 3",
       iPadAir4 = "iPad Air 4",
       iPadAir5 = "iPad Air 5",
       iPad5 = "iPad 5", // iPad 2017
       iPad6 = "iPad 6", // iPad 2018
       iPad7 = "iPad 7", // iPad 2019
       iPad8 = "iPad 8", // iPad 2020
       iPad9 = "iPad 9", // iPad 2021

       // iPad Mini
       iPadMini = "iPad Mini",
       iPadMini2 = "iPad Mini 2",
       iPadMini3 = "iPad Mini 3",
       iPadMini4 = "iPad Mini 4",
       iPadMini5 = "iPad Mini 5",
       iPadMini6 = "iPad Mini 6",

       // iPad Pro
       iPadPro9_7 = "iPad Pro 9.7\"",
       iPadPro10_5 = "iPad Pro 10.5\"",
       iPadPro11 = "iPad Pro 11\"",
       iPadPro2_11 = "iPad Pro 11\" 2nd gen",
       iPadPro3_11 = "iPad Pro 11\" 3rd gen",
       iPadPro12_9 = "iPad Pro 12.9\"",
       iPadPro2_12_9 = "iPad Pro 2 12.9\"",
       iPadPro3_12_9 = "iPad Pro 3 12.9\"",
       iPadPro4_12_9 = "iPad Pro 4 12.9\"",
       iPadPro5_12_9 = "iPad Pro 5 12.9\"",

       // iPhone
       iPhone4 = "iPhone 4",
       iPhone4S = "iPhone 4S",
       iPhone5 = "iPhone 5",
       iPhone5S = "iPhone 5S",
       iPhone5C = "iPhone 5C",
       iPhone6 = "iPhone 6",
       iPhone6Plus = "iPhone 6 Plus",
       iPhone6S = "iPhone 6S",
       iPhone6SPlus = "iPhone 6S Plus",
       iPhoneSE = "iPhone SE",
       iPhone7 = "iPhone 7",
       iPhone7Plus = "iPhone 7 Plus",
       iPhone8 = "iPhone 8",
       iPhone8Plus = "iPhone 8 Plus",
       iPhoneX = "iPhone X",
       iPhoneXS = "iPhone XS",
       iPhoneXSMax = "iPhone XS Max",
       iPhoneXR = "iPhone XR",
       iPhone11 = "iPhone 11",
       iPhone11Pro = "iPhone 11 Pro",
       iPhone11ProMax = "iPhone 11 Pro Max",
       iPhoneSE2 = "iPhone SE 2nd gen",
       iPhone12Mini = "iPhone 12 Mini",
       iPhone12 = "iPhone 12",
       iPhone12Pro = "iPhone 12 Pro",
       iPhone12ProMax = "iPhone 12 Pro Max",
       iPhone13Mini = "iPhone 13 Mini",
       iPhone13 = "iPhone 13",
       iPhone13Pro = "iPhone 13 Pro",
       iPhone13ProMax = "iPhone 13 Pro Max",
       iPhoneSE3 = "iPhone SE 3nd gen",

       // Apple Watch
       AppleWatch1 = "Apple Watch 1gen",
       AppleWatchS1 = "Apple Watch Series 1",
       AppleWatchS2 = "Apple Watch Series 2",
       AppleWatchS3 = "Apple Watch Series 3",
       AppleWatchS4 = "Apple Watch Series 4",
       AppleWatchS5 = "Apple Watch Series 5",
       AppleWatchSE = "Apple Watch Special Edition",
       AppleWatchS6 = "Apple Watch Series 6",
       AppleWatchS7 = "Apple Watch Series 7",

       // Apple TV
       AppleTV1 = "Apple TV 1gen",
       AppleTV2 = "Apple TV 2gen",
       AppleTV3 = "Apple TV 3gen",
       AppleTV4 = "Apple TV 4gen",
       AppleTV_4K = "Apple TV 4K",
       AppleTV2_4K = "Apple TV 4K 2gen",

       unrecognized = "?unrecognized?"
}

// MARK: UIDevice extensions

public extension UIDevice {
  var type: Model {
    var systemInfo = utsname()
    uname(&systemInfo)
    let modelCode = withUnsafePointer(to: &systemInfo.machine) {
      $0.withMemoryRebound(to: CChar.self, capacity: 1) {
        ptr in String(validatingUTF8: ptr)
      }
    }

    let modelMap: [String: Model] = [
      // Simulator
      "i386": .simulator,
      "x86_64": .simulator,

      // iPod
      "iPod1,1": .iPod1,
      "iPod2,1": .iPod2,
      "iPod3,1": .iPod3,
      "iPod4,1": .iPod4,
      "iPod5,1": .iPod5,
      "iPod7,1": .iPod6,
      "iPod9,1": .iPod7,

      // iPad
      "iPad2,1": .iPad2,
      "iPad2,2": .iPad2,
      "iPad2,3": .iPad2,
      "iPad2,4": .iPad2,
      "iPad3,1": .iPad3,
      "iPad3,2": .iPad3,
      "iPad3,3": .iPad3,
      "iPad3,4": .iPad4,
      "iPad3,5": .iPad4,
      "iPad3,6": .iPad4,
      "iPad6,11": .iPad5, // iPad 2017
      "iPad6,12": .iPad5,
      "iPad7,5": .iPad6, // iPad 2018
      "iPad7,6": .iPad6,
      "iPad7,11": .iPad7, // iPad 2019
      "iPad7,12": .iPad7,
      "iPad11,6": .iPad8, // iPad 2020
      "iPad11,7": .iPad8,
      "iPad12,1": .iPad9, // iPad 2021
      "iPad12,2": .iPad9,

      // iPad Mini
      "iPad2,5": .iPadMini,
      "iPad2,6": .iPadMini,
      "iPad2,7": .iPadMini,
      "iPad4,4": .iPadMini2,
      "iPad4,5": .iPadMini2,
      "iPad4,6": .iPadMini2,
      "iPad4,7": .iPadMini3,
      "iPad4,8": .iPadMini3,
      "iPad4,9": .iPadMini3,
      "iPad5,1": .iPadMini4,
      "iPad5,2": .iPadMini4,
      "iPad11,1": .iPadMini5,
      "iPad11,2": .iPadMini5,
      "iPad14,1": .iPadMini6,
      "iPad14,2": .iPadMini6,

      // iPad Pro
      "iPad6,3": .iPadPro9_7,
      "iPad6,4": .iPadPro9_7,
      "iPad7,3": .iPadPro10_5,
      "iPad7,4": .iPadPro10_5,
      "iPad6,7": .iPadPro12_9,
      "iPad6,8": .iPadPro12_9,
      "iPad7,1": .iPadPro2_12_9,
      "iPad7,2": .iPadPro2_12_9,
      "iPad8,1": .iPadPro11,
      "iPad8,2": .iPadPro11,
      "iPad8,3": .iPadPro11,
      "iPad8,4": .iPadPro11,
      "iPad8,9": .iPadPro2_11,
      "iPad8,10": .iPadPro2_11,
      "iPad13,4": .iPadPro3_11,
      "iPad13,5": .iPadPro3_11,
      "iPad13,6": .iPadPro3_11,
      "iPad13,7": .iPadPro3_11,
      "iPad8,5": .iPadPro3_12_9,
      "iPad8,6": .iPadPro3_12_9,
      "iPad8,7": .iPadPro3_12_9,
      "iPad8,8": .iPadPro3_12_9,
      "iPad8,11": .iPadPro4_12_9,
      "iPad8,12": .iPadPro4_12_9,
      "iPad13,8": .iPadPro5_12_9,
      "iPad13,9": .iPadPro5_12_9,
      "iPad13,10": .iPadPro5_12_9,
      "iPad13,11": .iPadPro5_12_9,

      // iPad Air
      "iPad4,1": .iPadAir,
      "iPad4,2": .iPadAir,
      "iPad4,3": .iPadAir,
      "iPad5,3": .iPadAir2,
      "iPad5,4": .iPadAir2,
      "iPad11,3": .iPadAir3,
      "iPad11,4": .iPadAir3,
      "iPad13,1": .iPadAir4,
      "iPad13,2": .iPadAir4,
      "iPad13,16": .iPadAir5,
      "iPad13,17": .iPadAir5,

      // iPhone
      "iPhone3,1": .iPhone4,
      "iPhone3,2": .iPhone4,
      "iPhone3,3": .iPhone4,
      "iPhone4,1": .iPhone4S,
      "iPhone5,1": .iPhone5,
      "iPhone5,2": .iPhone5,
      "iPhone5,3": .iPhone5C,
      "iPhone5,4": .iPhone5C,
      "iPhone6,1": .iPhone5S,
      "iPhone6,2": .iPhone5S,
      "iPhone7,1": .iPhone6Plus,
      "iPhone7,2": .iPhone6,
      "iPhone8,1": .iPhone6S,
      "iPhone8,2": .iPhone6SPlus,
      "iPhone8,4": .iPhoneSE,
      "iPhone9,1": .iPhone7,
      "iPhone9,3": .iPhone7,
      "iPhone9,2": .iPhone7Plus,
      "iPhone9,4": .iPhone7Plus,
      "iPhone10,1": .iPhone8,
      "iPhone10,4": .iPhone8,
      "iPhone10,2": .iPhone8Plus,
      "iPhone10,5": .iPhone8Plus,
      "iPhone10,3": .iPhoneX,
      "iPhone10,6": .iPhoneX,
      "iPhone11,2": .iPhoneXS,
      "iPhone11,4": .iPhoneXSMax,
      "iPhone11,6": .iPhoneXSMax,
      "iPhone11,8": .iPhoneXR,
      "iPhone12,1": .iPhone11,
      "iPhone12,3": .iPhone11Pro,
      "iPhone12,5": .iPhone11ProMax,
      "iPhone12,8": .iPhoneSE2,
      "iPhone13,1": .iPhone12Mini,
      "iPhone13,2": .iPhone12,
      "iPhone13,3": .iPhone12Pro,
      "iPhone13,4": .iPhone12ProMax,
      "iPhone14,4": .iPhone13Mini,
      "iPhone14,5": .iPhone13,
      "iPhone14,2": .iPhone13Pro,
      "iPhone14,3": .iPhone13ProMax,
      "iPhone14,6": .iPhoneSE3,

      // Apple Watch
      "Watch1,1": .AppleWatch1,
      "Watch1,2": .AppleWatch1,
      "Watch2,6": .AppleWatchS1,
      "Watch2,7": .AppleWatchS1,
      "Watch2,3": .AppleWatchS2,
      "Watch2,4": .AppleWatchS2,
      "Watch3,1": .AppleWatchS3,
      "Watch3,2": .AppleWatchS3,
      "Watch3,3": .AppleWatchS3,
      "Watch3,4": .AppleWatchS3,
      "Watch4,1": .AppleWatchS4,
      "Watch4,2": .AppleWatchS4,
      "Watch4,3": .AppleWatchS4,
      "Watch4,4": .AppleWatchS4,
      "Watch5,1": .AppleWatchS5,
      "Watch5,2": .AppleWatchS5,
      "Watch5,3": .AppleWatchS5,
      "Watch5,4": .AppleWatchS5,
      "Watch5,9": .AppleWatchSE,
      "Watch5,10": .AppleWatchSE,
      "Watch5,11": .AppleWatchSE,
      "Watch5,12": .AppleWatchSE,
      "Watch6,1": .AppleWatchS6,
      "Watch6,2": .AppleWatchS6,
      "Watch6,3": .AppleWatchS6,
      "Watch6,4": .AppleWatchS6,
      "Watch6,6": .AppleWatchS7,
      "Watch6,7": .AppleWatchS7,
      "Watch6,8": .AppleWatchS7,
      "Watch6,9": .AppleWatchS7,

      // Apple TV
      "AppleTV1,1": .AppleTV1,
      "AppleTV2,1": .AppleTV2,
      "AppleTV3,1": .AppleTV3,
      "AppleTV3,2": .AppleTV3,
      "AppleTV5,3": .AppleTV4,
      "AppleTV6,2": .AppleTV_4K,
      "AppleTV11,1": .AppleTV2_4K
    ]

    if let model = modelMap[String(validatingUTF8: modelCode!)!] {
      if model == .simulator {
        if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
          if let simModel = modelMap[String(validatingUTF8: simModelCode)!] {
            return simModel
          }
        }
      }
      return model
    }
    return Model.unrecognized
  }
}
