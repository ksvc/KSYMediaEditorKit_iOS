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
#import "KSYFilterCfg.h"


/**
 录制视频单元，存储一条视频的信息
 */
@interface KSYMediaUnit : NSObject

/**
 本地视频路径
 */
@property(nonatomic, strong)NSString *path;

/**
 视频长度
 */
@property(nonatomic, assign)CMTime duration;

@end


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
 @see KSYFilterCfg
 @see GPUImageFilter
 */
- (void)setupFilterCfg:(KSYFilterCfg *)filterCfg;

/**
设置filter
*/
- (void)setupFilter:(GPUImageOutput<GPUImageInput> *)filter;

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

 @param index 要删除的视频位置
 @warning 正在录制时调用无效
 */
- (void)deleteRecordedVideoAt:(NSInteger)index;


- (void)deleteAllRecordedVideo;

/**
 前后摄像头切换
 */
- (void) switchCamera;

/**
 @abstract   该函数表征摄像头具备开启闪光灯的能力
 @return     YES / NO
 */
- (BOOL) isTorchSupported;

/**
 @abstract   开关闪光灯
 @discussion 切换闪光灯的开关状态 开 <--> 关
 */
- (void) toggleTorch;

/**
 是否静音

 @param mute YES:静音 NO:不静音
 */
- (void) muteAudio:(BOOL)mute;

/**
 音量调节默认音量为1.0, startPreview之后生效,
 音量比例（0.0~1.0）溢出内部自动纠正到边界范围
 @param origin 原音，这里是指采集到的麦克风声音
 @param bgm    背景音
 */
- (void) adjustVolume:(float)origin bgm:(float)bgm;

/**
 获取音量

 @param origin mic音量
 @param bgm 背景音音量
 */
- (void) getVolume:(float *)origin bgm:(float *)bgm;
/**
 是否正在录制
 */

@property(assign, readonly, getter=isRecording)BOOL recording;

/**
 参考 AVCaptureSessionPreset*
 */
@property(nonatomic, strong)NSString *sessionPreset;

/**
 视频录制帧率
 */
@property(nonatomic, assign) int videoFrameRate;

/**
 预览分辨率 (仅在开始采集前设置有效)，内部始终将较大的值作为宽度 (目前sdk内部videoOrientation指定为竖屏），
 宽高都会向上取整为4的整数倍，有效范围: 宽度[160, 1920] 高度[ 90,  1080], 超出范围会取边界有效值，
 当预览分辨率与采集分辨率不一致时:
    若宽高比不同, 先进行裁剪, 再进行缩放
    若宽高比相同, 直接进行缩放
 默认值为(1280, 720)
 */
@property(nonatomic, assign) CGSize previewDimension;

/**
 录制视频码率, 默认4000
 */
@property (nonatomic, assign) int   videoBitrate;

/**
 录制音频码率， 默认96
 */
@property (nonatomic, assign) int   audioBitrate;

/**
 @abstract   用户定义的视频 **输出** 分辨率
 @discussion 有效范围: 宽度[160, 1280] 高度[ 90,  720], 超出范围会取边界有效值
 @discussion 其他与previewDimension限定一致,
 @discussion 当与previewDimension不一致时, 同样先裁剪到相同宽高比, 再进行缩放
 @discussion 默认值为(640, 360)
 @see previewDimension
 */
@property(nonatomic, assign) CGSize outputVideoDimension;

/**
 摄像头位置，前置／后置
 */
@property(nonatomic, assign) AVCaptureDevicePosition cameraPosition;

/**
 录制文件路径
 */
@property(nonatomic, strong) NSString *outputPath UNAVAILABLE_ATTRIBUTE;

/**
 保存录制文件的集合
 */
@property(strong, readonly)NSArray<__kindof KSYMediaUnit *> *recordedVideos;


/**
 已经录制完成的视频时长，不包括正在录制的时长
 */
@property(assign, readonly)NSTimeInterval  recordedLength;

/**
 最短录制时长, 视频集合的总时长必须大于该值，默认为3s
 
 */
@property(nonatomic, assign)NSTimeInterval minRecDuration;


/**
 最长录制时长，视频集合的总时长必须小于该值，当录制时长超过该值后内部自动停止录制, 默认sdk本身不限制，但必须大于minRecDuration
 */
@property(nonatomic, assign)NSTimeInterval maxRecDuration;


@property(nonatomic, weak)id<KSYCameraRecorderDelegate> delegate;

/**
 @abstract  背景音乐播放器, startPreview之后生效
 */
@property (nonatomic, readonly) KSYBgmPlayer  *bgmPlayer;


#pragma mark “混响、变声目前仅对mic有效”
/**
 @abstract 混响类型
 @discussion 目前提供了4种类型的混响场景, type和场景的对应关系如下
 - 0 关闭
 - 1 录音棚
 - 2 ktv
 - 3 小舞台
 - 4 演唱会
 */
@property(nonatomic, assign) int reverbType;

/**
 @abstract 音效类型
 */
@property(nonatomic, assign) KSYAudioEffectType effectType;

/**
 @abstract 触摸缩放因子，用于调节焦距(0.0 - 1.0)
 */
@property (nonatomic, assign) CGFloat pinchZoomFactor;

/**
 手动曝光
 
 @param point 坐标
 */
- (void)exposureAtPoint:(CGPoint)point;

/**
 手动对焦

 @param point 焦点坐标
 */
- (void)focusAtPoint:(CGPoint)point;

@end




@protocol KSYCameraRecorderDelegate <NSObject>


/**
  完成一次录制回调，超过最大录制长度而停止录制时不会有该回调
 @param sender 相应的实例
 @param length 已经录制的视频总长度
 */
-(void)cameraRecorder:(KSYCameraRecorder *)sender didFinishRecord:(NSTimeInterval)length;

/**
 更新录制的进度
 1.stopRecord之后不再回调
 2.达到maxRecDuration之后不再回调

 @param sender 相应的实例
 @param lastRecordLength 最新录制的一条视频已录制的长度
 @param totalLength 录制视频集合的总长度
 @warning 使用者应该尽可能快的返回该函数
 */
-(void)cameraRecorder:(KSYCameraRecorder *)sender lastRecordLength:(NSTimeInterval)lastRecordLength totalLength:(NSTimeInterval)totalLength;

/**
  达到最大录制长度限制的回调,只有设置了maxRecDuration之后才有可能收到该回调

 @param sender 相应的实例
 @param maxRecDuration 最大长度
 */
-(void)cameraRecorder:(KSYCameraRecorder *)sender didReachMaxDurationLimit:(NSTimeInterval)maxRecDuration;

@end
