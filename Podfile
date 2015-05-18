platform :ios, '8.0'

pod 'Parse', '1.7.1'
pod 'ParseUI', '1.1'
pod 'ParseCrashReporting', '1.7.1'
pod 'MBProgressHUD', '0.8'
pod 'PBWebViewController', '0.2'
pod 'SDWebImage', '3.7.1'
pod 'Reachability', '3.1.1'
pod 'CocoaLumberjack', '1.9.1'
pod 'PBYouTubeVideoViewController', '1.0.1'
pod 'QuickDialog', '1.0'

#pod 'Reveal-iOS-SDK', '~> 1.0'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-acknowledgements.plist', 'Kidney John/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
