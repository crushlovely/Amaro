platform :ios, '7.0'

# Inform CocoaPods that we use some custom build configurations
xcodeproj 'CrushBootstrap',
  'Debug_Staging'   => :debug,   'Debug_Production'   => :debug,
  'Test_Staging'    => :debug,   'Test_Production'    => :debug,
  'AdHoc_Staging'   => :release, 'AdHoc_Production'   => :release,
  'Profile_Staging' => :release, 'Profile_Production' => :release,
  'Distribution'    => :release

# Crush Utility Belt
pod 'Sidecar'

# Update checker for Installr (installrapp.com)
pod 'Aperitif'

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


# Copy the license and settings plists over to our project
post_install do |installer|
  require 'fileutils'

  if Dir.exists?('CrushBootstrap/Resources/Settings.bundle') && File.exists?('Pods/Pods-Acknowledgements.plist')
    FileUtils.cp_r('Pods/Pods-Acknowledgements.plist', 'CrushBootstrap/Resources/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
  end

  if File.exists?('Pods/Pods-Environment.h')
    FileUtils.cp_r('Pods/Pods-Environment.h', 'CrushBootstrap/Other-Sources/Pods-Environment.h', :remove_destination => true)
  end
end
