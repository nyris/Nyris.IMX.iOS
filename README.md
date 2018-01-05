project 'EverybagExpress.xcodeproj'

platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'EverybagExpress' do
  use_frameworks!
  
  #pod 'EverybagSDK', "~> 0.3.4"
  pod 'NyrisSDK', :git => 'https://github.com/nyris/Nyris.IMX.iOS.git', :tag => '0.3.7' #'/Users/Anas/Desktop/ios_dev/everybag/ios/NyrisSDK/'
  pod 'Kingfisher', '~> 4.5'
  
  target 'EverybagExpressTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'EverybagExpressUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
