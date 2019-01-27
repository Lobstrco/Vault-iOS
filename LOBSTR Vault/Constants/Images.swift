// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  internal typealias AssetColorTypeAlias = NSColor
  internal typealias AssetImageTypeAlias = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  internal typealias AssetColorTypeAlias = UIColor
  internal typealias AssetImageTypeAlias = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Colors {

    internal static let background = ColorAsset(name: "Colors/Background")
    internal static let black = ColorAsset(name: "Colors/Black")
    internal static let cellBorder = ColorAsset(name: "Colors/CellBorder")
    internal static let confirm = ColorAsset(name: "Colors/Confirm")
    internal static let darkIndigo = ColorAsset(name: "Colors/DarkIndigo")
    internal static let gray = ColorAsset(name: "Colors/Gray")
    internal static let grayOpacity30 = ColorAsset(name: "Colors/GrayOpacity30")
    internal static let grayOpacity70 = ColorAsset(name: "Colors/GrayOpacity70")
    internal static let main = ColorAsset(name: "Colors/Main")
    internal static let red = ColorAsset(name: "Colors/Red")
    internal static let white = ColorAsset(name: "Colors/White")
  }
  internal enum Icons {

    internal enum Other {
      internal static let delete = ImageAsset(name: "Icons/Other/delete")
      internal static let icClose = ImageAsset(name: "Icons/Other/icClose")
      internal static let icCopy = ImageAsset(name: "Icons/Other/icCopy")
      internal static let icFinger = ImageAsset(name: "Icons/Other/icFinger")
      internal static let icKey = ImageAsset(name: "Icons/Other/icKey")
      internal static let icPlus = ImageAsset(name: "Icons/Other/icPlus")
      internal static let icQuestionSign = ImageAsset(name: "Icons/Other/icQuestionSign")
    }
    internal enum Tabbar {
      internal static let arrowsFill = ImageAsset(name: "Icons/Tabbar/arrowsFill")
      internal static let arrowsOut = ImageAsset(name: "Icons/Tabbar/arrowsOut")
      internal static let icHomeFill = ImageAsset(name: "Icons/Tabbar/icHomeFill")
      internal static let icHomeOut = ImageAsset(name: "Icons/Tabbar/icHomeOut")
      internal static let settingsFill = ImageAsset(name: "Icons/Tabbar/settingsFill")
      internal static let settingsOut = ImageAsset(name: "Icons/Tabbar/settingsOut")
    }
  }
  internal enum Other {

    internal static let logo = ImageAsset(name: "Other/logo")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ColorAsset {
  internal fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  internal var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

internal extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct DataAsset {
  internal fileprivate(set) var name: String

  #if os(iOS) || os(tvOS) || os(OSX)
  @available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
  internal var data: NSDataAsset {
    return NSDataAsset(asset: self)
  }
  #endif
}

#if os(iOS) || os(tvOS) || os(OSX)
@available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
internal extension NSDataAsset {
  convenience init!(asset: DataAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(name: asset.name, bundle: bundle)
    #elseif os(OSX)
    self.init(name: NSDataAsset.Name(asset.name), bundle: bundle)
    #endif
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  internal var image: AssetImageTypeAlias {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = AssetImageTypeAlias(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = AssetImageTypeAlias(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

internal extension AssetImageTypeAlias {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
