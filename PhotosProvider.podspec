Pod::Spec.new do |s|

  s.name         = "PhotosProvider"
  s.version      = "0.3.0"
  s.summary      = "Use combined PhotoObjects."
  s.description  = "You can use Photos Framework easily"

  s.homepage     = "http://github.com/muukii/PhotosProvider"

  s.license      = "MIT"
  s.requires_arc = true
  s.author             = { "muukii" => "m@muukii.me" }
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/muukii/PhotosProvider.git", :tag => "#{s.version}" }

  s.source_files  = "PhotosProvider/Classes/**/*.swift"
  s.exclude_files = "Classes/Exclude"
  s.frameworks  = "Foundation", "GCDKit"
  s.dependency "GCDKit", "~> 1.2"

end
