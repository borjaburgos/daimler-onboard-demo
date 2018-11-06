project 'DemoSwift/DemoSwift.xcodeproj'
platform :ios, '10.0'

target 'DemoSwift' do
  use_frameworks!
  pod 'CocoaLumberjack/Swift'

  target 'DemoSwiftTests' do
    inherit! :search_paths
    pod 'Codescope', :git => "https://github.com/undefinedlabs/ios-agent.git", :branch => "logger"
    pod 'Codescope/CocoaLumberjack', :git => "https://github.com/undefinedlabs/ios-agent.git", :branch => "logger"
  end

  target 'DemoSwiftUITests' do
    inherit! :search_paths
    pod 'Codescope', :git => "https://github.com/undefinedlabs/ios-agent.git", :branch => "logger"
    pod 'Codescope/CocoaLumberjack', :git => "https://github.com/undefinedlabs/ios-agent.git", :branch => "logger"
  end

end
