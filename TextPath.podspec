Pod::Spec.new do |s|
  s.name             = 'TextPath'
  s.version          = '1.0.1'
  s.summary          = 'A library to convert NSAttributedText TO SVG path.'
  s.description      = <<-DESC
  A library to convert NSAttributedText TO SVG path.
  List of supported features:
  - [x] NSAttributedString.Key.strikethroughStyle
  - [x] NSAttributedString.Key.underlineStyle
  - [x] NSAttributedString.Key.kern
  - [x] NSAttributedString.Key.font
  - [x] NSAttributedString.Key.paragraphStyle
  - [ ] Support RTL language
  - [x] Support right alignment texts
                       DESC
  s.homepage         = 'https://github.com/mehdok/TextPath.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mehdi Sohrabi' => 'mehdok@gmail.com' }
  s.source           = { :git => 'https://github.com/mehdok/TextPath.git', :tag => s.version.to_s }
  s.ios.deployment_target = '14.0'
  s.swift_version = '5' 
  s.source_files = 'Sources/TextPath/Classes/**/*'
end
