//
//  KSYMediaEditor.h
//  KSYMediaEditorKit
//
//  Created by 张俊 on 31/03/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYDefines.h"
#import "KSYMETimeLineItem.h"
#import <libksygpulive/libksystreamerengine.h>

@class GPUImageOutput;
@protocol GPUImageInput;
@protocol KSYMEComposeDelegate;
@protocol KSYMEPreviewDelegate;

typedef void (^KSYMEPrepareBlock)(BOOL success);

@interface KSYMediaEditor : NSObject
/**
 @abstract 设置该delegate,以便接收内部回调，addVideo之前设置有效
 */
@property (nonatomic, weak) id<KSYMEComposeDelegate> delegate;

/**
 @abstract 用以接收预览播放器状态及进度,addVideo之前设置有效
 */
@property (nonatomic, weak) id<KSYMEPreviewDelegate> previewDelegate;


/**
 @abstract 创建KSYMediaEditor对象 (不支持m3u8格式)
 @param url 待编辑的视频url
 @discussion 多视频需要使用KSYMEConcator进行拼接后再进行编辑
 */
- (instancetype)initWithURL:(NSURL *)url;


/**
 预览视图
 */
@property (nonatomic, strong) KSYGPUView *previewView;

/**
 创建KSYMediaEditor对象(支持m3u8格式)

 @param url 待编辑的视频url
 @param complete 是否准备完成
 @return 当前对象
 */
- (instancetype)initWithURL:(NSURL *)url
            prepareComplete:(KSYMEPrepareBlock)complete;

/**
 @abstract 播放编辑过的视频（尚未合成）
 @param view   承载播放视图的控件
 @param isLoop 是否循环播放，以添加的视频文件为参考
 */
- (void)startPreview:(UIView *)view loop:(BOOL)isLoop;

/**
 @abstract
     播放指定范围的视频
 
 @param view   承载播放视图的控件
 @param range 要播放的范围，如果输入范围超出视频范围，会自动纠正为视频范围
     比如range.start < video.start 实际为video.start
     range.duration > video.duration实际为video.duration
     range 会自动纠正为[kCMTimeZero, video.duration]范围内
 @param isLoop 选中的范围是否循环播放
 
 @discussion
     目前仅支持对单个视频进行range播放，调用该接口进行预览播放后，startProcessVideo会自动裁剪range范围内的视频
 */
- (void)startPreview:(UIView *)view range:(CMTimeRange)range isLoop:(BOOL)isLoop;

/**
 @abstract 暂停正在播放的视频
 */

- (void)pausePreview;

/**
 @abstract 恢复播放
 */
- (void)resumePreview;

/**
 @abstract 关闭预览播放
 
 @discussion
     1. 停止预览之后需要重新调用setupPlayView
     2. 美颜、水印需要重新设置
 */
- (void)stopPreview;

/**
 @abstract
     设置视频预览回调间隔

 @param timeInterval 回调间隔时间
 @discussion
     timeInterval 为kCMTimeZero
 */
- (void)setPreviewProgressCallbackInterval:(CMTime)timeInterval;

/**
 @abstract
     添加一首背景音，添加的音乐播放状态自动跟随预览视频的状态（若果预览视频正在播放，则bgm自动播放，否则在startPreview之后播放）
 
 @param path  背景音乐, 如果path  为空则停止播放背景音
 @param loop YES, 音乐循环播放:
                     1.如果音乐的长度大于视频文件长度，则取视频文件长度，不循环
                     2.如果音乐长度小于视频文件长度，循环播放
             NO, 总长度取视频长度，不足部分留空
 @discussion
     1.新添加的会覆盖之前已添加的；
     2.正在合成中，添加无效
     3.startPreview前调用有效
 */
- (void)addBgm:(NSString *)path loop:(BOOL)loop;

/**
 @abstract 音量调节， 范围 [0~1.0]

 @param raw 视频音量
 */
- (void)adjustRawVolume:(float)raw;

/**
 @abstract 音量调节， 范围 [0~1.0]
 
 @param bgm 背景音量
 */
- (void)adjustBGMVolume:(float)bgm;

/**
 @abstract 获取音量
 
 @param raw 视频音量
 @param bgm 背景音音量
 */
- (void)getVolume:(float *)raw bgm:(float *)bgm;


/**
 获取当前的预览时间
 
 @return 时间 (秒)
 */
- (CMTime)getPreviewCurrentTime;

/**
 @abstract 滤镜
 */
@property (nonatomic) GPUImageOutput<GPUImageInput> *filter;
/**
 @abstract 设置水印相关参数

 @param image 水印图像（nil表示去除水印）
 @param logoRect rect位置、大小
                 origin : 坐标原点[0-1]
                 size   : 水印占画面比例[0-1] 只需设置宽或高的比例，另一个值传0即可
 @param alpha 透明度
 */
- (void)setWaterMarkImage:(UIImage *)image waterMarkRect:(CGRect)logoRect andAplpha:(CGFloat)alpha;

/**
 @abstract 编辑预览seek功能,startProcessVideo之后不要掉用该接口
 
 @param time 需要seek到的时间点
 @param range 新的播放范围,用户必须保证该参数正确，以正确裁剪
 
 @discussion 只需要seek，不需要变更裁剪区间，可以设置range为 kCMTimeRangeInvalid
 */
- (void)seekToTime:(CMTime)time range:(CMTimeRange)range finish:(dispatch_block_t)finish;


/**
 @abstract 编辑预览 BGM seek功能,startProcessVideo之后不要掉用该接口
 
 @param time 需要seek到的时间点
 @param range 新的播放范围,用户必须保证该参数正确，以正确裁剪
 
 @discussion 只需要seek，不需要变更裁剪区间，可以设置range为 kCMTimeRangeInvalid
 */
- (void)seekBGMToTime:(CMTime)time range:(CMTimeRange)range finish:(dispatch_block_t)finish;

/**
 @abstract 编辑预览倍速播放功能
 
 @discussion
     0      : 暂停
     1      : 正常播放
     目前支持变速倍速 [0.5, 2.0]
 */
- (void)setPlayerRate:(float)rate;

/**
 @abstract 设置混响类型
 */
- (void)setReverbType:(KSYMEReverbType)reverbType;

/**
 @abstract 设置音效类型
 */
- (void)setEffectType:(KSYAudioEffectType)effectType;

/**
 @abstract 视频输出格式, 具体可设置参考KSYDefines.h文件
 */
@property (nonatomic, strong) NSDictionary *outputSettings;

/**
 @abstract
     贴纸容器视图
 
 @discussion
     所有贴纸、字幕、mv等，都添加在该容器中
 */
@property (nonatomic, weak) UIView *uiElementView;

/**
 @abstract 
     特效模型数组
 
 @discussion
     贴纸、字幕 等对应的时间模型数据，对应于uiElementView上的对象
     有增删模型，调用set方法进行update模型，内部控制uiElementView上UI是否渲染
     合成时，会根据timeLineItems进行
 */
@property (nonatomic,readonly, weak) NSArray<KSYMETimeLineItem *> *timeLineItems;

/**
 @abstract
      删除制定的 KSYMETimeLineItem
 
 @param item KSYMETimeLineItem
 */
- (void)deleteTimeLineItem:(KSYMETimeLineItem *)item;

/**
  增加 MV 模型

 @param item KSYMETimeLineItem/KSYMETimeLineItem subclass
 */
- (void)addTimeLineItem:(KSYMETimeLineItem *)item;


/**
 更新模型时间

 @param item 被修改的 item
 */
- (void)updateTimeLineItem:(KSYMETimeLineItem *)item;

/**
 @abstract
     开始处理视频，异步任务
 
 @discussion
     视频裁剪、滤镜、裁剪、水印等
     目前sdk对视频的一系列处理(滤镜、裁剪、水印 etc)只支持对一条视频的处理, 请使用addVideo来进行这些操作
 */
- (void)startProcessVideo;

/**
 @abstract
 停止处理视频，异步任务
 
 @discussion
 视频裁剪、滤镜、裁剪、水印等
 目前sdk对视频的一系列处理(滤镜、裁剪、水印 etc)只支持对一条视频的处理, 请使用addVideo来进行这些操作
 */

- (void)stopProcessVideo;



@end



/**
 @abstract 视频合成转码状态、进度代理
 */
@protocol KSYMEComposeDelegate <NSObject>

@required
/**
 @abstract 合成错误回调
 
 @param editor   editor 对应的实例
 @param err      错误码
 @param extraStr extraStr
 */
- (void)onComposeError:(KSYMediaEditor*)editor err:(KSYStatusCode)err extraStr:(NSString*)extraStr;

@optional
/**
 @abstract 媒体文件处理进度
 
 @param value 进度 [0.0f - 1.0f]
 */
- (void)onComposeProgressChanged:(float)value;

/**
 @abstract 媒体文件处理完成触发

 @param path 合成完成后文件在沙盒中的路径
 @param thumbnail 合成完成后的视频的封面图
 */
- (void)onComposeFinish:(NSURL *)path thumbnail:(UIImage *)thumbnail;

@end



/**
 @abstract 视频编辑预览代理
 */
@protocol KSYMEPreviewDelegate <NSObject>


/**
 编辑时开启预览失败, 当合成转码或准备视频文件情况下开启预览可能失败
 @param error 错误描述
 */
- (void)onPlayStartFail:(NSError *)error;

@optional
/**
 @abstract 播放状态

 @param status 播放状态
 */
- (void)onPlayStatusChanged:(KSYMEPreviewStatus)status;
    
/**
 @abstract 播放进度
 
 @param time 要播放的范围
 @param percent  该范围内已经播放的百分比
 */
- (void)onPlayProgressChanged:(CMTimeRange)time percent:(float)percent;

@end

