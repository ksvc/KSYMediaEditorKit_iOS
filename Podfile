# Uncomment the next line to define a global platform for your project
platform :ios, '8.0'
#use_frameworks!

dev_path=ENV['KSYLIVEDEMO_DIR']

workspace 'demo.xcworkspace'
target 'demo' do
    project 'demo.xcodeproj'
    pod 'Bugly'
    pod 'Masonry'
    pod 'Ks3SDK', '~> 1.7.2'
    pod 'YYKit'
    pod 'MBProgressHUD'
    pod 'HMSegmentedControl'
    pod 'ICGVideoTrimmer'
    pod 'KSYAudioPlotView'

#    pod 'libksygpulive/libksygpulive', :git => 'git@newgit.op.ksyun.com:sdk/KSYLive_iOS.git' , :tag 'v2.7.0.0'
#    pod 'libksygpulive/libksygpulive_265', '~> 2.7.0.0'
    pod 'libksygpulive/libksygpulive_265', :path => dev_path

    pod 'KMCSTFilter'
    pod 'CTAssetsPickerController',  '~> 3.3.0'
    pod 'KMCVStab'
    pod 'FDFullscreenPopGesture', '1.1'
    pod 'SMPageControl'
end
