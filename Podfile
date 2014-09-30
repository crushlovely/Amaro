source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'

# Crush Utility Belt
pod 'Sidecar'

# Update checker for Installr (installrapp.com)
pod 'Aperitif', :configurations => ['Debug_Staging', 'Debug_Production', 'AdHoc_Staging', 'AdHoc_Production']

# Logging & Analytics
pod 'CocoaLumberjack'
pod 'CrashlyticsFramework'
pod 'CrashlyticsLumberjack'

# Networking
pod 'AFNetworking'

# Various goodies
pod 'libextobjc'      # Useful macros and some craziness
pod 'PixateFreestyle' # Style your app with CSS
pod 'FormatterKit'    # For all your string formatting needs
pod 'Asterism'        # Nice & fast collection operations

# You may want...
#pod 'PromiseKit'     # Promises/A+-alike
#pod 'Mantle'         # Github's model framework
#pod 'SSKeychain'     # Go-to keychain wrapper
#pod 'DateTools'      # Datetime heavy lifting


# Testing necessities
target 'Specs', :exclusive => true do
  pod 'Specta'
  pod 'Expecta'
  pod 'OCMockito'

# pod 'OHHTTPStubs'
end


# Inform CocoaPods that we use some custom build configurations
# Leave this in place unless you've tweaked the project's targets and configurations.
xcodeproj 'CrushBootstrap',
  'Debug_Staging'   => :debug,   'Debug_Production'   => :debug,
  'Test_Staging'    => :debug,   'Test_Production'    => :debug,
  'AdHoc_Staging'   => :release, 'AdHoc_Production'   => :release,
  'Profile_Staging' => :release, 'Profile_Production' => :release,
  'Distribution'    => :release


# After every installation, copy the license and settings plists over to our project
post_install do |installer|
  require 'fileutils'

  acknowledgements_plist = 'Pods/Target Support Files/Pods/Pods-Acknowledgements.plist'
  if Dir.exists?('CrushBootstrap/Resources/Settings.bundle') && File.exists?(acknowledgements_plist)
    FileUtils.cp(acknowledgements_plist, 'CrushBootstrap/Resources/Settings.bundle/Acknowledgements.plist')
  end

  environment_file = 'Pods/Target Support Files/Pods/Pods-environment.h'
  if File.exists?(environment_file)
    FileUtils.cp(environment_file, 'CrushBootstrap/Other-Sources/Pods-Environment.h')
  end
end
