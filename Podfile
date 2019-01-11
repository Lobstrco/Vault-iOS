platform :ios, '10.0'
inhibit_all_warnings!

target 'LOBSTR Vault' do

  use_frameworks!

  # The Soneso open source stellar SDK for iOS & Mac provides APIs to build transactions and connect to Horizon.
  pod 'stellar-ios-mac-sdk', '~> 1.5.6'
  
  pod 'Firebase/Core'
  pod 'Fabric', '~> 1.9.0'
  pod 'Crashlytics', '~> 3.12.0'

  target 'LOBSTR VaultTests' do
    inherit! :search_paths
  end

end
