#
#  Be sure to run `pod spec lint KSYMediaEditorKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "libksygpulive"
  s.module_name  = 'libksygpulive'
  s.version      = "2.3.0"
  s.summary      = "ksyun iOS mediaeditor sdk "
  s.description  = <<-DESC
                    * ksyun mediaeditor sdk 
                   DESC

  s.homepage     = "http://v.ksyun.com/doc.html"


  s.license      = {:type => 'Proprietary', :text => <<-LICENSE
      Copyright 2015 kingsoft Ltd. All rights reserved.
      LICENSE
  }

  s.author       = { "Noiled" => "Noiled@163.com" }

  s.ios.deployment_target = "7.0"

  s.source       = { :git => "git@newgit.op.ksyun.com:sdk/KSYShortVideoiOS.git", :tag => "#{s.version}" }

  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC -all_load' }
  s.ios.library = 'z', 'iconv', 'stdc++.6', 'bz2'
  s.requires_arc = true


  s.dependency 'GPUImage'
  s.dependency 'Ks3SDK', '~> 1.7.2'
  s.default_subspec = 'libksygpulive_265'

  # Internal dependency 
  subLibs = [ 'base','yuv','mediacodec',
              'mediacore_dec_lite',
              'mediacore_dec_vod',
              'mediacore_enc_lite',
              'mediacore_enc_265',
              'mediacore_enc_base',
              'streamerbase',
              'streamerengine',
              'gpufilter']
  subLibs.each do |subName|
    s.subspec subName do |sub|
      sub.vendored_library = 'libs/libksy%s.a' % subName
    end
  end
  # lite version of KSYMediaPlayer (less decoders)
  s.subspec 'KSYMediaPlayer' do |sub|
    sub.source_files =  'include/KSYPlayer/*.h'
    sub.vendored_library = 'libs/libksyplayer.a'
    sub.dependency '%s/base' % s.name
    sub.dependency '%s/mediacore_dec_lite' % s.name
  end
  # vod version of KSYMediaPlayer (more decoders)
  s.subspec 'KSYMediaPlayer_vod' do |sub|
    sub.source_files =  'include/KSYPlayer/*.h'
    sub.vendored_library = 'libs/libksyplayer.a'
    sub.dependency '%s/base' % s.name
    sub.dependency '%s/mediacore_dec_vod' % s.name
  end
  s.subspec 'libksygpulive' do |sub|
    sub.source_files =  ['include/**/*.h',
                         'source/*.{h,m}']
    sub.vendored_library = ['libs/libksyplayer.a'];
    sub.dependency 'GPUImage'
    sub.dependency '%s/base' % s.name
    sub.dependency '%s/yuv' % s.name
    sub.dependency '%s/mediacodec' % s.name
    sub.dependency '%s/mediacore_enc_base' % s.name
    sub.dependency '%s/mediacore_enc_lite' % s.name
    sub.dependency '%s/streamerbase' % s.name
    sub.dependency '%s/streamerengine' % s.name
    sub.dependency '%s/gpufilter' % s.name
  end
  s.subspec 'libksygpulive_noKit' do |sub|
    sub.source_files =  ['include/**/*.h']
    sub.vendored_library = ['libs/libksyplayer.a'];
    sub.dependency 'GPUImage'
    sub.dependency '%s/base' % s.name
    sub.dependency '%s/yuv' % s.name
    sub.dependency '%s/mediacodec' % s.name
    sub.dependency '%s/mediacore_enc_base' % s.name
    sub.dependency '%s/mediacore_enc_lite' % s.name
    sub.dependency '%s/streamerbase' % s.name
    sub.dependency '%s/streamerengine' % s.name
    sub.dependency '%s/gpufilter' % s.name
  end
  s.subspec 'libksygpulive_265' do |sub|
    sub.source_files =  ['include/KSYStreamer/*.h',
                         'include/KSYPlayer/*.h',
                         'source/*.{h,m}']
    sub.vendored_library = ['libs/libksyplayer.a'];
    sub.dependency 'GPUImage'
    sub.dependency '%s/base' % s.name
    sub.dependency '%s/yuv' % s.name
    sub.dependency '%s/mediacodec' % s.name
    sub.dependency '%s/mediacore_enc_base' % s.name
    sub.dependency '%s/mediacore_enc_265' % s.name
    sub.dependency '%s/streamerbase' % s.name
    sub.dependency '%s/streamerengine' % s.name
    sub.dependency '%s/gpufilter' % s.name
  end
  s.subspec 'KSYGPUResource' do |sub|
    sub.resource = 'resource/KSYGPUResource.bundle'
  end
  s.subspec 'ksyplayer_d' do |sub|
    sub.source_files =  'include/**/*.h';
    sub.vendored_library = 'libs/libksyplayer.a';
    sub.dependency 'GPUImage'
    sub.dependency '%s/base' % s.name
    sub.dependency '%s/yuv' % s.name
    sub.dependency '%s/mediacodec' % s.name
    sub.dependency '%s/mediacore_enc_base' % s.name
    sub.dependency '%s/mediacore_enc_lite' % s.name
  end


  #  conform to master's code file reference 
  # s.resource = 'deps/resource/KSYGPUResource.bundle'

end
