//
//  KSYMediaEditor.h
//  KSYMediaEditorKit
//
//  Created by 张俊 on 31/03/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSYDefines.h"
#import "KSYWaterMarkCfg.h"
#import "KSYFilterCfg.h"
#import "KSYVideoPreviewPlayerDelegate.h"
#import <libksygpulive/libksystreamerengine.h>
#import "GPUImage/GPUImage.h"

@class GPUImageOutput;
@class GPUImageInput;
@protocol KSYMediaEditorDelegate;
@protocol KSYVideoPreviewPlayerDelegate;

@interface KSYMediaEditor : NSObject

+ (instancetype)sharedInstance;

/**
 *   添加一个待处理的视频文件到编辑引擎
 *      仅支持本地文件
 *  @param path 本地文件地址
 *  @return 是否添加成功
 *  @warning  1.目前仅支持添加一条视频，新添加的视频将会覆盖之前添加的视频
 *            2.频处理进行中时不能操作
 *
 */
- (KSYStatusCode)addVideo:(NSString *)path;
/**
 *   添加多个待处理的视频文件到编辑引擎
 *
 *  @param paths 文件列表, 无效文件不会被添加
 *  @warning 1.目前对多段视频的操作，仅支持多段视频合成
 *           2.视频合成进行中时不能操作
             3.调用该接口会清空编辑引擎内部缓存的视频列表(非删除文件)
 *
 */
- (KSYStatusCode)addVideos:(NSArray<__kindof NSString *> *)paths;

/**
 添加一首背景音，添加的音乐播放状态自动跟随预览视频的状态（若果预览视频正在播放，则bgm自动播放，否则在startPreview之后播放）
 1.新添加的会覆盖之前已添加的；
 2.正在合成中，添加无效
 3.startPreview前调用有效
 @param path  背景音乐, 如果path  为空则停止播放背景音
 @param loop YES, 音乐循环播放，
                     1.如果音乐的长度大于视频文件长度，则取视频文件长度，不循环
                     2.如果音乐长度小于视频文件长度，循环播放
                NO, 总长度取视频长度，不足部分留空
 */
- (void)addBgm:(NSString *)path loop:(BOOL)loop;


/**
 音量调节， 范围 [0~1.0]

 @param raw 视频音量
 @param bgm 背景音量
 */
- (void) adjustVolume:(float)raw bgm:(float)bgm;

/**
 获取音量
 @param raw 视频音量
 @param bgm 背景音音量
 */
- (void) getVolume:(float *)raw bgm:(float *)bgm;

/**
 *  移除一条要处理的视频
 *
 *  @param path 视频对应的路径
 *  @warning 视频处理进行中时不能操作
 */
- (void)removeVideo:(NSString *)path  UNAVAILABLE_ATTRIBUTE;

/**
 *  设置播放view, 如果需要预览效果，需要设置该接口
 *
 *  @param view 播放view
 */
- (void)setupPlayView:(UIView *)view;

/**
 *  设置水印
 *
 *  @param filter 滤镜配置相关
 */
- (void)setupFilter:(KSYFilterCfg *)filter;

/**
 *  设置水印
 *
 *  @param waterMark 水印相关参数
 */
- (void)setWaterMark:(KSYWaterMarkCfg *)waterMark;

/**
 播放编辑过的视频（尚未合成）

 @param isLoop 是否循环播放，以添加的视频文件为参考
 */
- (void)startPreview:(BOOL)isLoop;

/**
 播放指定范围的视频
 @param range 要播放的范围，如果输入范围超出视频范围，会自动纠正为视频范围
        比如range.start < video.start 实际为video.start
           range.duration > video.duration实际为video.duration
           range 会自动纠正为[kCMTimeZero, video.duration]范围内
 @param isLoop 选中的范围是否循环播放
 @warning 目前仅支持对单个视频进行range播放，调用该接口进行预览播放后，startProcessVideo会自动裁剪range范围内的视频
 */
- (void)startPreviewAtRange:(CMTimeRange)range isLoop:(BOOL)isLoop;

/**
 *  暂停正在播放的视频
 */

- (void)pausePreview;

/**
 *  停止预览播放
 *  1.停止预览之后需要重新调用setupPlayView
 *  2. 美颜、水印需要重新设置
 */
- (void)stopPreview;


/**
 编辑预览seek功能,startProcessVideo之后不要掉用该接口
 @param time 需要seek到的时间点
 @param range 新的播放范围,用户必须保证该参数正确，以正确裁剪
 */
- (void)seekToTime:(CMTime)time range:(CMTimeRange)range finish:(dispatch_block_t)finish;;

/**
 开始处理视频，异步任务
 
 - 视频拼接
 调用addVideos添加视频之后调用startProcessVideo会将添加的视频按先后顺序自动拼接为1条视频输出。
 注意：添加多条视频时，目前只支持拼接操作
 
 - 视频裁剪、滤镜、裁剪、水印等
 目前sdk对视频的一系列处理(滤镜、裁剪、水印 etc)只支持对一条视频的处理, 请使用addVideo来进行这些操作
 
 */
- (void)startProcessVideo;

/**
 *  取消任务, 暂不支持
 */
- (void)cancel;


/**
 ks3 上传参数

 @param params 参数字典
        包括下面的key
            KSYUploadBucketName 必填
            KSYUploadObjKey     必填
            KSYUploadDomain     可选
 @param uploadParamblock 参考KSYGetUploadParamBlock(NSDictionary *params, KSYUploadWithTokenBlock block)
         1.params回调一组参数(包括HttpMethod、ContentType、Resource、Headers、ContentMd5)，客户使用这些参数从自己的服务器计算ks3上传的token及Date信息
         2.uploadParamblock块的第二个参数也是一个block，用于客户设置token及Date
         更具体的参考KSYDefines.h中的定义
 */
- (void)setUploadParams:(NSDictionary *)params uploadParamblock:(KSYGetUploadParamBlock)uploadParamblock ;


/**
 *  水印相关设置
 */
@property (nonatomic, strong)KSYWaterMarkCfg *waterMark;

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
 *  视频输出格式, 具体可设置参考KSYDefines.h文件
 */
@property(nonatomic, strong)NSDictionary *outputSettings;

/**
 @abstract   贴纸容器视图
 @discussion 所有贴纸、字幕、mv等，都添加在该容器中
 */
@property (nonatomic, strong) UIView *uiElementView;

/**
 *  设置该delegate,以便接收内部回调，addVideo之前设置有效
 */
@property (nonatomic, weak)id<KSYMediaEditorDelegate> delegate;


/**
 用以接收预览播放器状态及进度,addVideo之前设置有效
 */
@property (nonatomic, weak)id<KSYVideoPreviewPlayerDelegate> previewPlayerDelegate;

@end


@protocol KSYMediaEditorDelegate <NSObject>

@optional
/**
 * sdk使用者应该实现该delegate，当收到后应该向app server请求KS3 的上传参数信息，
 * 然后调用setUploadParams配置参数以便sdk进行文件上传
 */
- (void)onKS3UpoloadParamsShouldSet;

/**
 *  上传进度
 *
 *  @param value from  0-1.0f
 */
- (void)onUploadProgressChanged:(float)value;


/**
 上传ks3完成

 @param path 播放地址
 
 */
- (void)onKS3UploadFinish:(NSString *)path;

/**
 *  媒体文件处理进度
 *  [0.0f - 1.0f]
 *  @param value 进度
 *  @warning not support yet, will support in the future
 */
- (void)onComposeProgressChanged:(float)value;

/**
 媒体文件处理完成触发

 @param path 合成完成后文件在沙盒中的路径
 @param thumbnail 合成完成后的视频的封面图
 */
- (void)onComposeFinish:(NSString *)path thumbnail:(UIImage *)thumbnail;


@required
/**
 *  KSYMediaEditor 内部的错误回调
 *
 *  @param editor   editor 对应的实例
 *  @param err      错误码
 *  @param extraStr extraStr
 */
- (void)onErrorOccur:(KSYMediaEditor*)editor err:(KSYStatusCode)err  extraStr:(NSString*)extraStr;

@end




