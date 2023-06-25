# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'Webasyst X' do
    # Comment the next line if you don't want to use dynamic frameworks
    use_frameworks!

    # Pods for Webasyst X
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'Webasyst'
    pod 'Moya'
    pod 'Moya/RxSwift'
    pod 'SnapKit', '~> 4.0'
    pod "JMMaskTextField-Swift"
    
    # Build settings configuration
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = 13.0
                config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'No'
            end
        end
    end
end
