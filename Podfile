project 'DemoSwift/DemoSwift.xcodeproj'
platform :ios, '10.0'

target 'DemoSwift' do
  use_frameworks!
  pod 'Alamofire', '~> 4.7'
  pod 'ScopeAgent'
  pod 'ScopeAgentClient'

  target 'DemoSwiftTests' do
    inherit! :search_paths
    pod 'ScopeAgent'
  end

  target 'DemoSwiftUITests' do
    inherit! :search_paths
    pod 'ScopeAgent'
  end

end
