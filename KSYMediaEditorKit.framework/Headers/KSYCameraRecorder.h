//
//  KSYCameraRecorder.h
//  KSYMediaEditorKit
//
//  Created by 张俊 on 20/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <libksygpulive/libksygpulive.h>
#import <libksygpulive/libksygpufilter.h>
#import <libksygpulive/libksystreamerengine.h>
#import "KSYDefines.h"
#import "KSYMETimeLineItem.h"

#pragma mark - KSYMediaUnit

/**
 录制视频单元，存储一条视频的信息
 */
@interface KSYMediaUnit : NSObject
/**
 本地视频路径
 */
@property(nonatomic, strong) NSURL *path;
/**
 视频长度
 */
@property(nonatomic, assign) CMTime duration;

@end



#pragma mark - KSYCameraRecorder

@protocol KSYCameraRecorderDelegate;
@interface KSYCameraRecorder : NSObject

/**
 开始预览
 @param parentView camera所在view的父view
 */
-(void)startPreview:(UIView *)parentView;

/**
 停止预览
 */
-(void)stopPreview;

/**
 开始录制视频,建议最短录制时长3s
 */
- (void)startRecord;


/**
 停止录制视频
 */

- (void)stopRecord:(void(^)(void))complete;
/**
 删除之前录制的某一段视频

 @param index 待删除的视频在recordedVideos中的index
 @warning 正在录制时调用无效，文件将会从沙盒中删除
 */
- (void)deleteRecordedVideoAt:(NSInteger)index;


/**
 删除所有录制的视频
 @warning recordedVideos中的所有文件将会从沙盒中删除
 */
- (void)deleteAllRecordedVideo;

/**
 前后摄像头切换
 */
- (void)switchCamera;

/**
 @abstract   该函数表征摄像头具备开启闪光灯的能力
 @return     YES / NO
 */
- (BOOL)isTorchSupported;

/**
 @abstract   开关闪光灯
 @discussion 切换闪光灯的开关状态 开 <--> 关
 */
- (void)toggleTorch;

/**
 是否静音

 @param mute YES:静音 NO:不静音
 */
- (void)muteAudio:(BOOL)mute;

/**
 音量调节默认音量为1.0, startPreview之后生效,
 音量比例（0.0~1.0）溢出内部自动纠正到边界范围
 @param origin 原音，这里是指采集到的麦克风声音
 */

- (void)adjustMicrophoneVolume:(float)origin;
/**
 音量调节默认音量为1.0, startPreview之后生效,
 音量比例（0.0~1.0）溢出内部自动纠正到边界范围
 @param bgm    背景音
*/

- (void)adjustBGMVolume:(float)bgm;
/**
 获取音量

 @param origin mic音量
 @param bgm 背景音音量
 */
- (void)getVolume:(float *)origin bgm:(float *)bgm;



/**
 @abstract
      apply mv theme
 
 @param filePath MV 资源文件路径
 
 @discussion
     zip解压后的文件夹全路径 eg:
     /var/mobile/Containers/Data/Application/F3AD88CD-4D1F-4AC0-AA6D-FD7B59863FC2/Documents/my_01
 */
- (void)applyMVFromeFilePath:(NSString *)filePath;

/**
 @abstract
     设置倍速录制
 
 @discussion 
     rate取值范围[0.5-2.0]，默认为1.0
     当带有BGM进行外放变速录制时，建议mute录音（microphone volume设置为0），避免从麦克风采集到的BGM杂音
     不支持MV的变速录制功能
 */
@property (nonatomic, assign) float recordRate;


/**
 是否正在录制
 */
@property (assign, readonly, getter=isRecording)BOOL recording;

/**
 参考 AVCaptureSessionPreset*
 */
@property (nonatomic, strong) NSString *sessionPreset;

/**
 视频录制帧率
 */
@property (nonatomic, assign) int videoFrameRate;

/**
 预览分辨率 (仅在开始采集前设置有效)，内部始终将较大的值作为宽度 (目前sdk内部videoOrientation指定为竖屏），
 宽高都会向上取整为4的整数倍，有效范围: 宽度[160, 1920] 高度[ 90,  1080], 超出范围会取边界有效值，
 当预览分辨率与采集分辨率不一致时:
    若宽高比不同, 先进行裁剪, 再进行缩放
    若宽高比相同, 直接进行缩放
 默认值为(1280, 720)
 */
@property (nonatomic, assign) CGSize previewDimension;

/**
 预览视图
 */
@property (nonatomic) KSYGPUView *preview;

/**
 录制视频码率, 默认4096
 */
@property (nonatomic, assign) int   videoBitrate;

/**
 录制音频码率， 默认64
 */
@property (nonatomic, assign) int   audioBitrate;

/**
 是否开启双声道，默认为NO
 */
@property (nonatomic, assign) BOOL bStereoAudioStream;

/**
 设置滤镜（MV中带有自定义滤镜组，使用MV时，该接口将不生效.MV 的滤镜组将替换当前滤镜）
 */
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;

/**
 @abstract   用户定义的视频 **输出** 分辨率
 @discussion 有效范围: 宽度[160, 1280] 高度[ 90,  720], 超出范围会取边界有效值
 @discussion 其他与previewDimension限定一致,
 @discussion 当与previewDimension不一致时, 同样先裁剪到相同宽高比, 再进行缩放
 @discussion 默认值为(640, 360)
 @see previewDimension
 */
@property (nonatomic, assign) CGSize outputVideoDimension;

/**
 摄像头位置，前置／后置
 */
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;

/**
 保存录制文件的集合
 */
@property (strong, readonly)NSArray<__kindof KSYMediaUnit *> *recordedVideos;

/**
 已经录制完成的视频时长，不包括正在录制的时长
 */
@property (assign, readonly)NSTimeInterval  recordedLength;

/**
 最短录制时长, 视频集合的总时长必须大于该值，默认为3s
 
 */
@property (nonatomic, assign)NSTimeInterval minRecDuration;


/**
 最长录制时长，视频集合的总时长必须小于该值，当录制时长超过该值后内部自动停止录制, 默认sdk本身不限制，但必须大于minRecDuration
 */
@property (nonatomic, assign)NSTimeInterval maxRecDuration;


@property (nonatomic, weak)id<KSYCameraRecorderDelegate> delegate;

/**
 @abstract  背景音乐播放器, startPreview之后生效
 
 MV 中如果带有BGM，将会替换当前BGM。当 MV 中带有音频时，不建议添加BGM
 */
@property (nonatomic, readonly) KSYBgmPlayer  *bgmPlayer;


#pragma mark “混响、变声目前仅对mic有效”
/**
 @abstract 混响类型
 */
@property (nonatomic, assign) KSYMEReverbType reverbType;

/**
 @abstract 音效类型
 */
@property (nonatomic, assign) KSYAudioEffectType effectType;

/**
 @abstract 触摸缩放因子，用于调节焦距(0.0 - 1.0)
 */
@property (nonatomic, assign) CGFloat pinchZoomFactor;

/**
 曝光补偿比例 (0 - 1.0) 0为无补偿，1为最大补偿
 @discussion setter 获取当前设备曝光补偿比例
             getter 设置设备曝光度补偿比例
 */
@property (nonatomic, assign) CGFloat exposureCompensation;
/**
 @abstract 手动曝光
 
 @param point 坐标
 */
- (void)exposureAtPoint:(CGPoint)point;

/**
 @abstract 手动对焦

 @param point 焦点坐标
 */
- (void)focusAtPoint:(CGPoint)point;

/**
 @abstract   摄像头朝向, 只在启动采集前设置有效
 @discussion 参见UIInterfaceOrientation
 @discussion 竖屏时: width < height
 @discussion 横屏时: width > height
 @discussion 需要与UI方向一致
 */
@property (nonatomic) UIInterfaceOrientation videoOrientation;

/**
 @abstract 旋转视频流预览方向
 @param    orie 旋转到目标朝向
 */
- (void)rotatePreviewTo:(UIInterfaceOrientation)orie;
/**
 @abstract 旋转视频流输出方向
 @param    orie 旋转到目标朝向
 */
- (void)rotateStreamTo:(UIInterfaceOrientation)orie;

/**
 @abstract 尝试开启视频防抖
 
 @param mode AVCaptureVideoStabilizationMode
 @return 是否开启成功
 @discussion 防抖模式会增加一定内存消耗
     1. iPhone前置摄像头不支持防抖功能
     2. 部分videoFormat不支持防抖模式
 */
- (BOOL)setStabilizationMode:(AVCaptureVideoStabilizationMode)mode;

#pragma mark - raw data
/**
 @abstract   视频处理回调接口
 @discussion sampleBuffer 原始采集到的视频数据
 @discussion 对sampleBuffer内的图像数据的修改将传递到观众端
 @discussion 请注意本函数的执行时间，如果太长可能导致不可预知的问题
 @discussion 请参考 CMSampleBufferRef
 */
@property (nonatomic, copy) void(^videoProcessingCallback)(CMSampleBufferRef sampleBuffer);

/**
 @abstract   音频处理回调接口
 @discussion sampleBuffer 原始采集到的音频数据
 @discussion 对sampleBuffer内的pcm数据的修改将传递到观众端
 @discussion 请注意本函数的执行时间，如果太长可能导致不可预知的问题
 @discussion 请参考 CMSampleBufferRef
 */
@property (nonatomic, copy) void(^audioProcessingCallback)(CMSampleBufferRef sampleBuffer);

/**
 @abstract   摄像头采集被打断的消息通知
 @discussion bInterrupt 为YES, 表明被打断, 摄像头采集暂停
 @discussion bInterrupt 为NO, 表明恢复采集
 */
@property (nonatomic, copy) void(^interruptCallback)(BOOL bInterrupt);

@end



#pragma mark - KSYCameraRecorderDelegate
@protocol KSYCameraRecorderDelegate <NSObject>

@optional

/**
 开始录制
 
 @param recorder instance of KSYCameraRecorder
 @param status   status of start record, noErr indicate start success,otherwise fail
 */
- (void)cameraRecorder:(KSYCameraRecorder *)recorder startRecord:(OSStatus)status;

/**
  完成一次录制回调，超过最大录制长度而停止录制时不会有该回调
 @param recorder 相应的实例
 @param length 已经录制的视频总长度
 */
- (void)cameraRecorder:(KSYCameraRecorder *)recorder didFinishRecord:(NSTimeInterval)length videoURL:(NSURL *)url;

/**
 更新录制的进度
 1.stopRecord之后不再回调
 2.达到maxRecDuration之后不再回调

 @param recorder 相应的实例
 @param lastRecordLength 最新录制的一条视频已录制的长度
 @param totalLength 录制视频集合的总长度
 @warning 使用者应该尽可能快的返回该函数
 */
- (void)cameraRecorder:(KSYCameraRecorder *)recorder lastRecordLength:(NSTimeInterval)lastRecordLength totalLength:(NSTimeInterval)totalLength;

/**
 达到最大录制长度限制的回调,只有设置了maxRecDuration之后才有可能收到该回调

 @param recorder 相应的实例
 @param maxRecDuration 最大长度
 */
- (void)cameraRecorder:(KSYCameraRecorder *)recorder didReachMaxDurationLimit:(NSTimeInterval)maxRecDuration;

@end
