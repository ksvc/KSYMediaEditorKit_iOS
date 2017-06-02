#
#  Be sure to run `pod spec lint KSYMediaEditorKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "KSYMediaEditorKit"
  s.module_name  = 'KSYMediaEditorKit'
  s.version      = "0.3.0"
  s.summary      = "ksyun iOS mediaeditor sdk "
  s.description  = <<-DESC
                    * ksyun mediaeditor sdk 
                   DESC

  s.homepage     = "http://v.ksyun.com/doc.html"


  s.license      = {:type => 'Proprietary', :text => <<-LICENSE
      Copyright 2015 kingsoft Ltd. All rights reserved.
      LICENSE
  }

  s.author       = { "KeChengWang" => "wangkecheng@kingsoft.com" }

  s.ios.deployment_target = "7.0"

  s.source       = { :git => "https://github.com/ksvc/KSYMediaEditorKit_iOS.git", :tag => "v#{s.version}" }

  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC -all_load' }

  s.requires_arc = true

  s.default_subspec = 'KSYMediaEditorKit'
  s.dependency 'Ks3SDK'
  s.dependency 'GPUImage'
  s.dependency 'libksygpulive', '2.3.0'
  
  s.subspec 'KSYMediaEditorKit' do |sub|
    sub.source_files = 'prebuilt/include/libKSYMediaEditorKit/*.h'
    sub.vendored_library = ['prebuilt/libs/liblibKSYMediaEditorKit.a']
  end
  #  conform to master's code file reference 

end
