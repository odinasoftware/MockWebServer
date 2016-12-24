#
# Be sure to run `pod lib lint MockWebServer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MockWebServer'
  s.version          = '0.1.3'
  s.summary          = 'Mock Web Server for XCTest in objective-c or swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A very simple web server, which is best for mocking web server's behavior.
You can determine how to respond and when to respond. Very easy to use and reliable.
                       DESC

  s.homepage         = 'https://github.com/odinasoftware/MockWebServer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jaehan' => 'odinasoftware@gmail.com' }
  s.source           = { :git => 'https://github.com/odinasoftware/MockWebServer.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MockWebServer/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MockWebServer' => ['MockWebServer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
