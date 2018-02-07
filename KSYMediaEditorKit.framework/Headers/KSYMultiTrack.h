//
//  KSYMultiTracks.h
//  KSYMediaEditorKit
//
//  Created by iVermisseDich on 2017/12/12.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <libksygpulive/libksystreamerengine.h>
#import "KSYDefines.h"

@class KSYMEAssetInfo;

typedef NS_ENUM(NSInteger, KSYMTStatus){
    KSYMTStatus_Idle,           // 空闲
    KSYMTStatus_Previewing,     // 预览       (未开放)
    KSYMTStatus_PreviewPaused,  // 预览暂停   （未开放）
    KSYMTStatus_Composing,      // 转码
    KSYMTStatus_ComposePaused   // 转码暂停
};

typedef NS_ENUM(NSInteger, KSYMEAssetType) {
    KSYMEAssetType_Video,     // 视频 (支持纯音频(audio)/无音频轨道(AN)/无视频轨道(VN) 的媒体文件)
    KSYMEAssetType_Audio,     
    KSYMEAssetType_Image,     // 图片
    KSYMEAssetType_DyImg      // 动态图片（未开放）
};

@interface KSYMultiTrack : NSObject

/**
 Indicates the output audioTrack's sound type.
 
 Default is NO, which means mono is default output sound type
 */
@property (nonatomic, assign) BOOL bStereo;


/**
 Indicates current multiTrack‘s status
 
 Default is KSYMTStatus_Idle
 */
@property (nonatomic, assign) KSYMTStatus status;

/**
 多画布合成
 
 @param assetInfoList video/audio/img资源及配置参数
 @param vbps 视频码率
 @param abps 音频码率
 @param resolution 分辨率
 @param error 错误回调
 @param progress 进度回调
 @param finish 完成回调
 
 @discussion
 下图示例为3个视频基于多画布进行视频合成，输出 400 * 600 分辨率的视频
 
 |─ ─ ─ ─ 400 ─ ─ ─ ─|
 ┌─────────┬─────────┐  ─
 │         │         │  |
 │         │ canvas1 │ 300
 │         │         │  |
 │         │         │  |
 │ canvas0 ├─────────┤  ─
 │         │         │  |
 │         │         │ 300
 │         │ canvas2 │  |
 │         │         │  |
 └─────────┴─────────┘  ─
 |── 200 ──|── 200 ──|
 
 输出视频时长会与coverVideos 中时长最长的视频保持一致
 coverVideos(包含3个video)中的视频将会按 coverRegions(包含3个region)中对应的 region 以'填充'模式进行绘制
 
 canvas0 在 (0,0,200,600) 的区域绘制，对应region为 (0, 0, 0.5, 1)
 canvas1 在 (200,0,200,300) 的区域绘制，对应region为 (0.5, 0, 0.5, 0.5)
 canvas2 在 (200,300,200,300) 的区域绘制，对应region为 (0.5, 0.5, 0.5, 0.5)
 */
- (void)jointAssetsWithInfoList:(NSArray<KSYMEAssetInfo *> *)assetInfoList
                           vbps:(NSInteger)vbps
                           abps:(NSInteger)abps
                     resolution:(CGSize)resolution
                       videoFPS:(NSInteger)fps
                          error:(void(^)(NSError *error))error
                       progress:(void(^)(float progress))progress
                         finish:(void(^)(NSURL *url))finish;


/**
 Pause composing if the multiTrack manager is composing
 */
- (void)pauseComposing;

/**
 Resume composing if the multiTrack manager is composing_paused
 */
- (void)resumeComposing;


/**
 Cancel current composing task
 
 Finish block will be invoked after cancelling current task
 */
- (void)cancelComposing;

@end



#pragma mark - KSYAssetInfo

/**
 输入源（Video、Audio、Image）合成参数
 KSYMETimeLineItem 暂不支持 KSYMEAssetInfo 设置
 */
@interface KSYMEAssetInfo : NSObject

/**
 An instance of NSURL that references a media resource.
 */
@property (nonatomic) NSURL *url;

/**
 indicate the type of current asset, default is KSYAssetType_Video
 */
@property (nonatomic, assign) KSYMEAssetType type;

/**
 Specifies a range of time that may limit the temporal portion of the receiver's asset from which media data will be read.
 
 @discussion
 - This property cannot be set after reading has started.
 - The default value of timeRange is CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity).
 - can only take effects for video, audio, dyImg
 */
@property (nonatomic, assign) CMTimeRange timeRange;

#pragma mark - Video Track
/**
 video、image render region
 
 - can only take effects for video, Image and dyImg
 - format：(x,y,s,t),each component‘s value range is [0，1]，default is (0,0,0,0)
 */
@property (nonatomic, assign) CGRect renderRegion;

/**
 video resize mode
 
 Default is fill mode
 */
@property (nonatomic, assign) KSYMEResizeMode resizeMode;
/**
 clip origin point
 
 若分辨率为100 * 200的视频，裁减掉B区域，只展示A区域，clipOrigin 为 (0，0)
 若分辨率为100 * 200的视频，裁减掉A区域，只展示B区域，clipOrigin 为 (0，0.5)
 ┌─────────┐  ─
 │         │  |
 │    A    │ 100
 │         │  |
 │─────────│  ─
 │         │  |
 │    B    │ 100
 │         │  |
 └─────────┘  ─
 |── 100 ──|
 */
@property (nonatomic, assign) CGPoint clipOrigin;

#pragma mark - Audio Track
/**
 volume of audio track
 
 - can only take effects for media which has audio track
 - value range is [0, 2.0], default is 1.0
 
 @warning if output sound type is mono, leftVolume is main Volume
 */
@property (nonatomic, assign) float leftVolume;

/**
 volume of audio track
 
 - can only take effects for media which has audio track
 - value range is [0, 2.0], default is 1.0
 
 @warning if output sound type is mono, rightVolume will not take effects
 */
@property (nonatomic, assign) float rightVolume;

#pragma mark - Audio Effect
/**
 @abstract 混响类型
 @discussion 目前提供了几种类型的混响场景, type和场景的对应关系如下
 */
@property (nonatomic, assign) KSYMEReverbType reverbType;

/**
 @abstract 音效类型
 
 @discussion 自定义类型 暂不开放
 */
@property (nonatomic, assign) KSYAudioEffectType aeType;

#pragma mark - params
@property (nonatomic) KSYTEType teType;
@property (nonatomic) NSDictionary *teParams;

@end
