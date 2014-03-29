platform :ios, '7.0'

# Inform CocoaPods that we use some custom build configurations
xcodeproj 'CrushBootstrap', 'AdHoc' => :release, 'Profile' => :release, 'Test' => :debug

# The Crush Bootstrap lib
pod 'CRLLib', :git => 'https://github.com/misterfifths/CRLLib.git'

# Logging & Analytics
pod 'CocoaLumberjack'
pod 'CrashlyticsFramework'
pod 'CrashlyticsLumberjack'

# Networking
pod 'AFNetworking'

# Various goodies
pod 'libextobjc'      # Useful macros and some craziness
pod 'FormatterKit'    # For all your string formatting needs
pod 'PixateFreestyle'

# You may want...
#pod 'OMPromises'     # Promises/A+-alike
#pod 'ReactiveCocoa'  # It's a lifestyle
#pod 'Mantle'         # Github's model framework
#pod 'SSKeychain'
#pod 'Asterism'       # Nice & fast collection operations


target 'Specs', :exclusive => true do
  pod 'Specta',    '~> 0.2.1'
  pod 'Expecta',   '~> 0.2.3'
  pod 'OCMockito', '~> 1.1.0'
end
