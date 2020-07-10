Pod::Spec.new do |s|
  s.name             = 'SchedJoulesSDK'
  s.version          = '0.9.13'
  s.summary          = 'The SchedJoules iOS SDK, written in Swift.'
 
  s.description      = <<-DESC
This pod contains classes which make it easier to interact with the SchedJoules API. Our SDK also uses the ApiClient, but if one does not need the full functionality of the SDK, or wants to build custom solutions instead, might find the ApiClient to be a good starting point.
                       DESC
 
  s.homepage         = 'https://github.com/schedjoules/ios-public-calendars-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Balazs Vincze' => 'sayhello@bvincze.com', 'Alberto Huerdo' => 'alberto@schedjoules.com' }
  s.source           = { :git => 'https://github.com/schedjoules/ios-public-calendars-sdk.git', :tag => s.version.to_s }

  s.swift_version = '4.0'
  s.ios.deployment_target = '11.4'
  s.source_files = 'SDK/**/*.swift'
  s.resource_bundles = {
    'SchedJoulesSDK' => ['SDK/*/*.{xib,storyboard,xcassets}']
  }

  s.dependency 'SDWebImage', '~> 4.0'
  s.dependency 'SchedJoulesApiClient'
 
end
