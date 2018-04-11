Pod::Spec.new do |s|

    s.name             = 'BxCoding'
    s.version = '1.0.0'
    s.summary          = '[BxCoding]'

    s.description      = '[BxCoding]'

    s.homepage         = 'https://github.com/borchero/BxCoding'
    s.license          = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.author           = { 'borchero' => 'borchero@icloud.com' }
    s.source           = { :git => 'https://github.com/borchero/BxCoding', :tag => s.version.to_s }

    s.ios.deployment_target = '11.0'

    s.source_files = 'BxCoding/**/*'

    s.dependency 'RxSwift'
    s.dependency 'BxUtility'

end

