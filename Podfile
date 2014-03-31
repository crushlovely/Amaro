platform :ios, '7.0'

# Inform CocoaPods that we use some custom build configurations
xcodeproj 'CrushBootstrap', 'AdHoc' => :release, 'Profile' => :release, 'Test' => :debug

# Crush internals
pod 'CRLLib', :git => 'https://github.com/crushlovely/CRLLib.git'
pod 'CRLInstallrChecker', :git => 'https://github.com/crushlovely/CRLInstallrChecker.git'

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
#pod 'OMPromises'     # Promises/A+-alike
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


# Copy the license settings plist over to our project
post_install do |installer|
    if Dir.exists? 'CrushBootstrap/Resources/Settings.bundle'
        require 'fileutils'
        FileUtils.cp_r('Pods/Pods-Acknowledgements.plist', 'CrushBootstrap/Resources/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
    end

    FileUtils.cp_r('Pods/Pods-Environment.h', 'CrushBootstrap/Pods-Environment.h', :remove_destination => true)
end
