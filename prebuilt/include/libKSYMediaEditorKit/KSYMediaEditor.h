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
//#import "GPUImage/GPUImage.h"


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
 *
 */
- (KSYStatusCode)addVideos:(NSArray<__kindof NSString *> *)paths;

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
 *  @param filter 水印配置相关
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

 @param isLoop 是否循环播放
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
 *  视频输出格式, 具体可设置参考KSYDefines.h文件
 */
@property(nonatomic, strong)NSDictionary *outputSettings;

/**
 *  水印相关设置
 */
@property (nonatomic, strong)KSYWaterMarkCfg *waterMark;


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




