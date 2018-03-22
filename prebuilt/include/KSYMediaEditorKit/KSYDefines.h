//
//  KSYStatusDefine.h
//  KSYMediaEditorKit
//
//  Created by iVermisseDich on 31/03/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#ifndef KSYDefines_h
#define KSYDefines_h
#import <AVFoundation/AVFoundation.h>

/**
 错误码
 */
typedef NS_ENUM(NSInteger, KSYStatusCode) {
    KSYRC_OK            = 0,
    /// 无效的appkey
    KSYRC_InvalidKey    = 1,
    /// 鉴权失败
    KSYRC_AuthFailed    = 2,
    /// token失效
    KSYRC_TokenExpired  = 3,
    /// 输入参数错误
    KSYRC_ParamErr      = 50,
    /// 暂不支持的特性
    KSYRC_NotSupport    = 100,
    
    /// 视频拼接失败
    KSYRC_IsConcating   = 110,
    KSYRC_ConcatFail    = 111,
    /// 合成失败
    KSYRC_ComposeErr    = 200,
    
    KSYRC_LowMem        = 500,
    KSYRC_DiskNotEnough = 510,
    
    /// 传入的文件不存在
    KSYRC_FileNotExist  = 511,
    KSYRC_CreateFileErr = 512,
    /// 无效的状态，sdk内部正在处理一些任务，调用的时机不正确
    KSYRC_InvalidState  = 900,
    KSYRC_UnknownErr    = 1000,
    KSYRC_TokenParseErr    = 1100, //传入的token未经我司授权
    KSYRC_TokenFormatErr    = 1101 //传入的token格式有问题
};


#pragma mark - 输出参数
/**
 输出格式
 
 - KSYOutputFormat_MP4: MP4
 - KSYOutputFormat_GIF: gif
 */
typedef NS_ENUM(NSUInteger, KSYOutputFormat){
    KSYOutputFormat_MP4,
    KSYOutputFormat_GIF,
};

/**
 画面裁剪/填充模式

 - KSYMEResizeModeFill: 填充模式
 - KSYMEResizeModeClip: 裁剪模式
 */
typedef NS_ENUM(NSInteger, KSYMEResizeMode){
    KSYMEResizeModeFill,    // 填充
    KSYMEResizeModeClip     // 裁剪
};

/// 输出视频的编码格式 （参考 KSYVideoCodec）
FOUNDATION_EXPORT NSString *const KSYVideoOutputCodec;
/// 输出视频的音频编码格式 (参考 KSYAudioCodec)
FOUNDATION_EXPORT NSString *const KSYVideoOutputAudioCodec;
/// 输出视频的宽，默认为720
FOUNDATION_EXPORT NSString *const kSYVideoOutputWidth;
/// 输出视频的高，默认为1280
FOUNDATION_EXPORT NSString *const kSYVideoOutputHeight;
/// 视频 resize 模式（参考 KSYMEResizeMode ，默认为 KSYMEResizeModeFill）
FOUNDATION_EXPORT NSString *const kSYVideoOutputResizeMode;
/** 
 @abstract 输出 resize 原点 ((x, y) x、y取值范围均为 0 ~ 1.0)
 视频 resize 模式为 KSYMEResizeModeClip 时裁剪坐标原点 (例：(0, 0.1)表示 绘制坐标系沿y轴向负方向移动0.1)
 视频 resize 模式为 KSYMEResizeModeFill 时填充坐标原点 (例：(0, 0.1)表示 绘制坐标系沿y轴向负方向移动0.1)
 */
FOUNDATION_EXPORT NSString *const KSYVideoOutputClipOrigin;
/// 输出视频的视频频码率 （默认 2048）
FOUNDATION_EXPORT NSString *const KSYVideoOutputVideoBitrate;
/// 输出视频的帧率
FOUNDATION_EXPORT NSString *const KSYVideoOutputFramerate;
/// 输出视频的音频码率 (默认 64)
FOUNDATION_EXPORT NSString *const KSYVideoOutputAudioBitrate;
/// 输出格式（参考 KSYOutputFormat，默认为 KSYOutputFormat_MP4）
FOUNDATION_EXPORT NSString *const KSYVideoOutputFormat;
/// 合成后的文件输出路径 (file:///)
FOUNDATION_EXPORT NSString *const KSYVideoOutputPath;
/// 需要拼接的片尾视频 (file:///)
FOUNDATION_EXPORT NSString *const KSYVideoTailLeaderVideoPath;

#pragma mark - 编辑时预览播放
/**
 预览播放状态，简化为以下状态，用户收到这些状态，应该只作UI的改变
 1.当调用startPreview之后，播放状态由KSYPreviewPlayerIdle 切换到 KSYPreviewPlayerPlay
 2.当一次播放完成后，如果开启了loop模式，则仍然为KSYPreviewPlayerPlay状态，否则切换为KSYPreviewPlayerStop状态
 3.当调用pausePreview后播放状态切换为KSYPreviewPlayerPause，调用者需要保证pausePreview在startPreview之后调用
 - KSYPreviewPlayerIdle:开始播放之前的状态，
 - KSYPreviewPlayerPlay:播放中
 - KSYPreviewPlayerPause:播放暂停
 - KSYPreviewPlayerStop:播放完成
 */
typedef NS_ENUM(NSInteger, KSYMEPreviewStatus){
    KSYPreviewPlayerIdle,
    KSYPreviewPlayerPlay,
    KSYPreviewPlayerPause,
    KSYPreviewPlayerStop,
};

#pragma mark - 混响
/*!
 混响类型
 */
typedef NS_ENUM(NSInteger, KSYMEReverbType){
    KSYMEReverbType_NONE = 0,            // 无
    KSYMEReverbType_RecordingRoom,       // 录音棚
    KSYMEReverbType_KTV,                 // ktv
    KSYMEReverbType_Woodwing,            // 小舞台
    KSYMEReverbType_Concert,             // 演唱会
};

#pragma mark - 缩略图、封面图
typedef NS_ENUM(NSInteger, KSYThumbnailGenResult)
{
    ///生成截图成功
    KSYThumbnailGenSucceeded,
    ///生成截图失败
    KSYThumbnailGenFailed,
    KSYThumbnailGenCancelled,
};

///截图相关参数
FOUNDATION_EXPORT NSString *const KSYThumbnailWith;
FOUNDATION_EXPORT NSString *const KSYThumbnailHeight;

/**
 截图block

 @param requestedTime 请求时间
 @param image 图像
 @param actualTime 真实截取图像的时间点
 @param result 截图结果
 @param error 错误信息
 */
typedef void (^KSYThumbnailGenHandler)(CMTime requestedTime, CGImageRef image, CMTime actualTime, KSYThumbnailGenResult result, NSError *error);



#pragma mark - MV Built-In Beauty Filter
typedef NS_ENUM(NSInteger, KSYMEBuiltInFilter){
    // Beauty Filter
    KSYMEBuiltInFilter_Ext      = 100,        // KSYGPUBeautifyExtFilter
    KSYMEBuiltInFilter_Pro      = 101,        // KSYBeautifyProFilter
    
    // Built-In Filter
    KSYMEBuiltInFilter_Effect   = 200,        // 特效滤镜
    KSYMEBuiltInFilter_Style    = 201,        // 风格滤镜
    KSYMEBuiltInFilter_SuperEffect = 202,     // 特效
    KSYMEBuiltInFilter_TimeEffect = 203       // 时间特效
};

/**
 特效滤镜类型
 - KSYSEType_Lightning 需要 KSYGPUResource.bundle 中包含资源 Lightening.png
 - KSYSEType_KTV 需要 KSYGPUResource.bundle 中包含资源 KTV.png
 */
typedef NS_ENUM(NSInteger, KSYSEType) {
    /// 放大抖动
    KSYSEType_ZOOM = 0,
    /// 彩色抖动
    KSYSEType_Color = 1,
    /// 冲击波
    KSYSEType_ShockWave = 2,
    /// Black magic
    KSYSEType_BlackMagic = 3,
    /// 闪电
    KSYSEType_Lightning = 4,
    /// KTV
    KSYSEType_KTV = 5,
    /// 幻觉
    KSYSEType_Illusion = 6,
    /// X-Signal
    KSYSEType_Xsignal = 7,
    /// 70s
    KSYSEType_70s = 8,
};
/**
 特效滤镜重叠模式
 
 @discussion
 - KSYSEBlendMode_Cover 覆盖模式，重叠部分的效果为最后添加的 filter 效果
 - KSYSEBlendMode_Overlap 叠加模式，重叠部分的效果为所有 filter 叠加后的效果
 */
typedef NS_ENUM(NSInteger, KSYSEBlendMode) {
    KSYSEBlendMode_Cover,            // 覆盖
    KSYSEBlendMode_Overlap           // 叠加
};

/**
 时间特效滤镜
 */
typedef NS_ENUM(NSInteger, KSYTEType){
    KSYTEType_NONE = 0,         // 关闭
    KSYTEType_Reverse,          // 倒放
    KSYTEType_Repeat,           // 重复
    KSYTEType_SlowMotion        // 慢动作
};

#endif /* KSYDefines_h */
