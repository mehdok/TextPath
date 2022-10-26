Pod::Spec.new do |s|
  s.name             = 'TextPath'
  s.version          = '1.0.2'
  s.summary          = 'A library to convert NSAttributedText TO SVG path.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/mehdok/TextPath.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mehdi Sohrabi' => 'mehdok@gmail.com' }
  s.source           = { :git => 'https://github.com/mehdok/TextPath.git', :tag => s.version.to_s }
  s.ios.deployment_target = '14.0'
  s.source_files = 'Sources/TextPath/Classes/**/*'
end
