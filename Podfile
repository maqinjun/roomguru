#
#  Podfile
#
#  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
#

# Pod sources
source 'https://github.com/CocoaPods/Specs.git'

# Initial configuration
platform :ios, '8.0'
inhibit_all_warnings!
use_frameworks!

xcodeproj 'Roomguru', 'Development' => :debug, 'Production' => :release, 'Staging' => :release, 'Test' => :debug

pod 'AFNetworking', '~> 2.6.3'

pod 'Alamofire', '~> 3.1.2’

pod 'Async',
    :git => "https://github.com/duemunk/Async.git",
    :tag => "1.4"

pod 'SwiftyJSON', '~> 2.3.1'

pod 'Cartography', '~> 0.6.0'

pod 'CryptoSwift',
    :git => "https://github.com/krzyzanowskim/CryptoSwift.git",
    :tag => "0.1.1"

pod 'AKPickerView-Swift', '~> 1.0.0'

pod 'SwiftyUserDefaults', '~> 2.0.0'

pod 'PKHUD',
    :git => "https://github.com/pkluz/PKHUD.git",
    :tag => "2.2.2"

pod 'FontAwesomeIconFactory', '~> 2.1.1'

target 'Tests' do link_with 'Unit Tests', 'Functional Tests'

    pod 'KIF', '~> 3.3',
        :configurations => ['Test']

    pod 'Quick', '~> 0.8.0',
        :configurations => ['Test']

    pod 'Nimble', '~> 3.0.0',
        :configurations => ['Test']
end

post_install do |installer|

    puts 'Setting appropriate code signing identities'
    installer.pods_project.targets.each { |target|
        {
            'iPhone Developer' => ['Debug', 'Development', 'Test'],
            'iPhone Distribution' => ['Release', 'Staging', 'Production'],
        }.each { |value, configs|
            target.set_build_setting('CODE_SIGN_IDENTITY[sdk=iphoneos*]', value, configs)
        }
    }

end

class Xcodeproj::Project::Object::PBXNativeTarget

    def set_build_setting setting, value, config = nil
        unless config.nil?
            if config.kind_of?(Xcodeproj::Project::Object::XCBuildConfiguration)
                config.build_settings[setting] = value
            elsif config.kind_of?(String)
                build_configurations
                .select { |config_obj| config_obj.name == config }
                .each { |config| set_build_setting(setting, value, config) }
            elsif config.kind_of?(Array)
                config.each { |config| set_build_setting(setting, value, config) }
            else
                raise 'Unsupported configuration type: ' + config.class.inspect
            end
        else
            set_build_setting(setting, value, build_configurations)
        end
    end

end
