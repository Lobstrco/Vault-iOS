platform :ios, '10.0'
inhibit_all_warnings!

target 'LOBSTR Vault' do

  use_frameworks!

  # The Soneso open source stellar SDK for iOS & Mac provides APIs to build transactions and connect to Horizon.
  pod 'stellar-ios-mac-sdk', '~> 1.5.6'
  
  # SwiftGen is a tool to auto-generate Swift code for resources of your projects, to make them type-safe to use.
  pod 'SwiftGen', '~> 6.0.2'
  
  # An iOS library to natively render After Effects vector animations
  pod 'lottie-ios', '~> 2.5.2'
  
  # Firebase.
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Fabric', '~> 1.9.0'
  pod 'Crashlytics', '~> 3.12.0'
  
  # A Swift based reimplementation of the Apple HUD 
  pod 'PKHUD', '~> 5.0'
  
  # Ready to use “Acknowledgements”/“Licenses”/“Credits” view controller for CocoaPods.
  pod 'AcknowList'

  target 'LOBSTR VaultTests' do
    inherit! :search_paths
  end

end
