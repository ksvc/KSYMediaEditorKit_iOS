Pod::Spec.new do |s|
  s.name         = 'KSYMediaEditorKit'
  s.version      = '0.0.1'
  s.license      = {
:type => 'Proprietary',
:text => <<-LICENSE
      Copyright 2015 kingsoft Ltd. All rights reserved.
      LICENSE
  }
  s.homepage     = 'http://v.ksyun.com/doc.html'
  s.authors      = { 'ksyun' => 'wangkecheng@kingsoft.com' }
  s.summary      = 'KSYMediaEditorKit 是金山云264、265短视频录制、编辑SDK.'
  s.description  = <<-DESC
   * KSYMediaEditorKit : x264/VT264/H265 short video clip sdk
  DESC
  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source = { :git => 'https://github.com/ksvc/KSYMediaEditorKit.git', :tag => "#{s.version}" }
  s.ios.library = 'z', 'iconv', 'stdc++.6', 'bz2'
  s.ios.frameworks   = [ 'AVFoundation', 'VideoToolbox']

  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC -all_load' }

  s.vendored_frameworks = 'libs/*.framework'
  s.resource = 'resource/KSYGPUResource.bundle'
  # s.subspec 'KSYMediaEditorKit' do |sub|
  #   sub.source_files =  'prebuilt/include/KSYMediaEditorKit/*.h'
  #   sub.vendored_library = 'prebuilt/libs/libKSYMediaEditorKit.a'
  # end

  s.dependency 'GPUImage'
  s.dependency 'Ks3SDK', '~> 1.7.2'
  
  
end