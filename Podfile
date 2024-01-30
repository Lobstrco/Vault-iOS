platform :ios, '12.0'
source 'https://github.com/CocoaPods/Specs.git'
inhibit_all_warnings!

target 'LOBSTR Vault' do

  use_frameworks!
#  use_modular_headers!

  # The Soneso open source stellar SDK for iOS & Mac provides APIs to build transactions and connect to Horizon.
  pod 'stellar-ios-mac-sdk', '~> 2.5.2'
  
  # SwiftGen is a tool to auto-generate Swift code for resources of your projects, to make them type-safe to use.
  pod 'SwiftGen', '~> 6.0.2'
  
  # An iOS library to natively render After Effects vector animations
  pod 'lottie-ios', '~> 2.5.2'
  
  # Firebase.
  pod 'Firebase/Analytics'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/Crashlytics'
  
  # A Swift based reimplementation of the Apple HUD
  pod 'PKHUD', '~> 5.0'
  
  # Ready to use "Acknowledgements"/"Licenses"/"Credits" view controller for CocoaPods.
  pod 'AcknowList', '~> 1.9.5'
  
  # A lightweight, pure-Swift library for downloading and caching images from the web.
  pod 'Kingfisher', '~> 5.0'
  
  # The Tangem card is a self-custodial hardware wallet for blockchain assets.
  pod 'TangemSdk', '~> 3.4.0'
  
  # A library to help you decode JWTs in Swift
  pod 'JWTDecode', '~> 2.4'

  # Delightful framework for iOS to easily persist structs, images, and data.
  pod 'Disk'

  # Swift wrapper for custom ViewController presentations on iOS.
  # https://github.com/IcaliaLabs/Presentr
  pod 'Presentr'

  target 'LOBSTR VaultTests' do
    inherit! :search_paths
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      config.build_settings['DEVELOPMENT_TEAM'] = "6ZVXG76XRR"
    end
  end
end
