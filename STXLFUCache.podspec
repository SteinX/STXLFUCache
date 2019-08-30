#
# Be sure to run `pod lib lint STXLFUCache.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'STXLFUCache'
  s.version          = '0.1.1'
  s.summary          = 'A simple LFU memory cache with constant time complexity for elementary operations'

  s.description      = <<-DESC
  A simple LFU memory cache with constant time complexity for elementary operations.
                       DESC

  s.homepage         = 'https://github.com/SteinX/STXLFUCache'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'SteinX' => 'steinxia@gmail.com' }
  s.source           = { :git => 'https://github.com/SteinX/STXLFUCache.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'STXLFUCache/Classes/**/*'
  s.private_header_files = 'STXLFUCache/Classes/Private/*.h'
  
  s.library = 'c++'
  s.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
    'CLANG_CXX_LIBRARY' => 'libc++'
  }
end
