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
  s.version      = "0.7.4"
  s.summary      = 'KSYMediaEditorKit 是金山云264、265短视频录制、编辑SDK.'
  s.description  = <<-DESC
                 * KSYMediaEditorKit : x264/VT264/H265 short video clip sdk
                   DESC

  s.homepage     = "http://v.ksyun.com/doc.html"

  s.license      = {:type => 'Proprietary', :text => <<-LICENSE
      Copyright 2017 kingsoft Ltd. All rights reserved.
      LICENSE
  }

  s.author       = { "Noiled" => "Noiled@163.com" }

  s.ios.deployment_target = "7.0"
  s.ios.frameworks   = [ 'AVFoundation', 'VideoToolbox']
  s.source = { :git => 'https://github.com/ksvc/KSYMediaEditorKit.git', :tag => "#{s.version}" }
  s.ios.library = 'z', 'iconv', 'stdc++.6', 'bz2'
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC -all_load' }

  s.requires_arc = true

  s.source_files = 'include/libKSYMediaEditorKit/*.h'
  s.vendored_library = 'libs/liblibKSYMediaEditorKit.a'

end
