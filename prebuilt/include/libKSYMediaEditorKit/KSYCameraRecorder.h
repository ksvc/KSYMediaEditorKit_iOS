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
#import "KSYFilterCfg.h"

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
 开始录制视频
/**
 开始录制视频,建议最短录制时长3s
 */
-(void)startRecord;


/**
 停止录制视频
 */
-(void)stopRecord;


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
 录制文件路径
 */
@property(nonatomic, strong) NSString *outputPath;

/**
 摄像头位置，前置／后置
 */
@property(nonatomic, assign) AVCaptureDevicePosition cameraPosition;

@end
