Pod::Spec.new do |s|
  s.name         = "RCCountDownView"
  s.version 	 = "0.1"
  s.summary      = "A simple count down view."
  s.homepage     = "https://github.com/RidgeCorn/RCCountDownView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors	 = { "Looping" => "www.looping@gmail.com" }

  s.platform     = :ios, '6.0'
  s.ios.deployment_target = '6.0'

  s.source       = { :git => "https://github.com/RidgeCorn/RCCountDownView.git", :tag => s.version.to_s }
  s.source_files  = 'RCCountDownView'
  s.public_header_files = 'RCCountDownView/*.h'

  s.requires_arc = true
end
