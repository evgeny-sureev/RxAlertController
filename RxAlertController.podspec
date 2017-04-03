#
# Be sure to run `pod lib lint RxAlertController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RxAlertController'
  s.version          = '1.0.3'
  s.summary          = 'A reactive wrapper built around UIAlertController.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
RxAlertController allows you to display messages on the screen, using the sequence of RxSwift observable streams instead of traditional closures.
                       DESC

  s.homepage         = 'https://github.com/evgeny-sureev/RxAlertController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author           = { 'Evgeny Sureev' => 'u@litka.ru' }
  s.source           = { :git => 'https://github.com/evgeny-sureev/RxAlertController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'RxAlertController/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RxAlertController' => ['RxAlertController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'RxSwift', '~> 3.0'
end
