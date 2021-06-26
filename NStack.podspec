Pod::Spec.new do |s|

  s.name             = 'NStack'
  s.version          = '0.0.2'
  s.summary          = 'Hoist navigation state into a coordinator in SwiftUI.'

  s.description      = <<-DESC
An NStack allows you to hoist SwiftUI navigation state into a higher-level 
coordinator view. The coordinator pattern allows you to write isolated views 
that have zero knowledge of their context within an app.
                       DESC

  s.homepage         = 'https://github.com/johnpatrickmorgan/NStack'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'johnpatrickmorgan' => 'johnpatrickmorganuk@gmail.com' }
  s.source           = { :git => 'https://github.com/johnpatrickmorgan/NStack.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/jpmmusic'


  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '11.0'
  s.watchos.deployment_target = '7.0'
  s.tvos.deployment_target = '13.0'

  s.swift_version = '5.4'

  s.source_files = 'Sources/**/*'
  
  s.frameworks = 'Foundation', 'SwiftUI'

end
