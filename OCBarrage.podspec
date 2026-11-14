Pod::Spec.new do |s|
  s.name = 'OCBarrage'
  # 对应 GitHub 2.0.0 版本；CocoaPods 发布独立进行。
  s.version = '2.0.0'
  s.summary = 'An extensible Swift iOS barrage renderer with reusable cells.'
  s.homepage = 'https://github.com/ios-strikers/OCBarrage'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'lifeichao' => 'lifeichao@qmtv.com' }
  s.source = { :git => 'https://github.com/ios-strikers/OCBarrage.git', :tag => s.version.to_s }
  s.platform = :ios, '15.0'
  s.swift_versions = ['6.0']
  s.source_files = 'OCBarrage/OCBarrage/*.swift'
  s.ios.frameworks = 'Foundation', 'UIKit', 'QuartzCore'
  s.requires_arc = true
end
