#
# Be sure to run `pod lib lint Popovers.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Popovers'
  s.version          = '1.0.4'
  s.summary          = 'A library to present popovers.'

  s.description      = <<-DESC
- Present any view above your app's main content.
- Attach to source views or use picture-in-picture positioning.
- Supports multiple popovers at the same time with smooth transitions.
- Popovers are interactive and can be dragged to different positions.
- Highly customizable API that's super simple — just add .popover.
- Written in SwiftUI with full SwiftUI and UIKit support.
                       DESC

  s.homepage         = 'https://github.com/aheze/Popovers'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'A. Zheng' => 'aheze@getfind.app' }
  s.source           = { :git => 'https://github.com/aheze/Popovers.git', :tag => s.version.to_s }

  s.social_media_url = 'https://twitter.com/aheze0'

  s.platform      = :ios, "13.0"

  s.source_files = 'Sources/**/*'
  s.swift_version = "5.5"

end
