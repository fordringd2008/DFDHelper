Pod::Spec.new do |s|
  s.name         = "DFDHelper"
  s.version      = '0.0.2'
  s.summary      = "Helper for ios."

  s.homepage     = "https://github.com/dingfude2008/DFDHelper"
  s.license      = "MIT"

  s.author       = { "dingfude2008" => "dingfude@qq.com" }
  s.source       = { :git => "https://github.com/dingfude2008/DFDHelper.git", :tag => s.version.to_s }
  s.source_files = "DFDHelper"
  s.platform	 = :ios, '7.0'
  s.framework    = 'UIKit','Foundation'
end