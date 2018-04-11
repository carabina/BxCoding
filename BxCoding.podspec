Pod::Spec.new do |s|

    s.name             = 'BxCoding'
    s.version = '1.0.0'
    s.swift_version    = '4.1'
    s.summary          = 'Beautiful and Safe Serialization of Json and Plists in Swift.'

    s.description      = 'BxCoding provides a beautiful way for reading Json and Plists'\
                         ' as well as for serialization. It aims to remove as many'\
                         ' conditional bindings as possible without throwing errors'\
                         ' until needed.'

    s.homepage          = 'https://bxcoding.borchero.com'
    s.documentation_url = 'https://bxcoding.borchero.com/docs'
    s.license           = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.author            = { 'Oliver Borchert' => 'borchero@icloud.com' }
    s.source            = { :git => 'https://github.com/borchero/BxCoding.git',
                            :tag => s.version.to_s }

    s.platform = :ios
    s.ios.deployment_target = '11.0'

    s.source_files = 'BxCoding/**/*'

    s.dependency 'RxSwift'
    s.dependency 'BxUtility'

    s.framework = 'Foundation'

end

