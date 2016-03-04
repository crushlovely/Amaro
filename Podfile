source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

# Uncomment this line if you need Swift support:
# use_frameworks!


# Crush Utility Belt
pod 'Sidecar', '~> 1.0'

# Logging & Analytics
pod 'CocoaLumberjack', '~> 2.0'

# Networking
pod 'AFNetworking'

# Various goodies
pod 'libextobjc'       # Useful macros and some craziness
pod 'Asterism'         # Nice & fast collection operations

# You may want...
#pod 'FormatterKit'    # For all your string formatting needs
#pod 'PromiseKit'      # Promises/A+-alike
#pod 'Mantle'          # Github's model framework
#pod 'SSKeychain'      # Go-to keychain wrapper
#pod 'DateTools'       # Datetime heavy lifting
#pod 'Masonry'         # Convenient autolayout DSL
#pod 'Reveal-iOS-SDK', :configurations => ['Debug_Staging', 'Debug_Production']

# Testing necessities
target 'Specs' do
  pod 'Specta'
  pod 'Expecta'
end


# Inform CocoaPods that we use some custom build configurations
# Leave this in place unless you've tweaked the project's targets and configurations.
xcodeproj 'CrushBootstrap',
  'Debug_Staging'   => :debug,   'Debug_Production'   => :debug,
  'Test_Staging'    => :debug,   'Test_Production'    => :debug,
  'AdHoc_Staging'   => :release, 'AdHoc_Production'   => :release,
  'Profile_Staging' => :release, 'Profile_Production' => :release,
  'Distribution'    => :release


# After every installation, copy the license settings plist over to our project
post_install do |installer|
  require 'fileutils'

  acknowledgements_plist = 'Pods/Target Support Files/Pods/Pods-Acknowledgements.plist'
  if Dir.exists?('CrushBootstrap/Resources/Settings.bundle') && File.exists?(acknowledgements_plist)
    FileUtils.cp(acknowledgements_plist, 'CrushBootstrap/Resources/Settings.bundle/Acknowledgements.plist')
  end
end
