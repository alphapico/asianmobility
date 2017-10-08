# Uncomment this line to define a global platform for your project
platform :ios, '9.0'

target 'Moovby' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Ignore warnings from pods
  inhibit_all_warnings!

  # Pods for Moovby
  pod 'GooglePlaces', '2.2.0'
  pod 'GooglePlacePicker', '2.2.0'
  pod 'GoogleMaps', '2.2.0'
  pod 'RealmSwift', '2.5.1'
  pod 'ObjectMapper', '2.2.5'
  pod 'Kingfisher', '3.6.1'
  pod 'PKHUD', '4.2.1'
  pod 'Alamofire', '4.4.0'
  pod 'Fabric', '1.6.11'
  pod 'Crashlytics', '3.8.4'
  pod 'DZNEmptyDataSet', '1.8.1'
  pod 'BWWalkthrough', '2.1.1'
  pod 'Firebase/Core'
  pod 'SwiftLint', '0.21.0'
  pod 'SwiftDate', '~> 4.3.0'
  pod 'IQKeyboardManager', '5.0.3'

  pod 'Bolts', '1.8.4'
  pod 'FBSDKCoreKit', '4.26.0'
  pod 'FBSDKShareKit', '4.26.0'
  pod 'FBSDKLoginKit', '4.26.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
