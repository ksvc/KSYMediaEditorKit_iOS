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
//#import "GPUImage/GPUImage.h"


@class GPUImageOutput;
@class GPUImageInput;
@protocol KSYMediaEditorDelegate;

@interface KSYMediaEditor : NSObject

+ (instancetype)sharedInstance;
/**
 *   添加一个待处理的视频文件到编辑引擎
 *      仅支持本地文件
 *  @param path 本地文件地址
 *  @return 是否添加成功
 *  @warning 频处理进行中时不能操作
 *
 */

- (KSYStatusCode)addVideo:(NSString *)path;

/**
 *   添加多个待处理的视频文件到编辑引擎
 *
 *  @param paths 文件列表, 无效文件不会被添加
 *  @warning 1.暂不支持
 *           2.视频处理进行中时不能操作
 *
 */
- (KSYStatusCode)addVideos:(NSArray<__kindof NSString *> *)paths;

/**
 *  移除一条要处理的视频
 *
 *  @param path 视频对应的路径
 *  @warning 视频处理进行中时不能操作
 */
- (void)removeVideo:(NSString *)path;

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
 *  播放编辑过的视频（尚未合成）
 */
- (void)startPreview;

/**
 *  暂停正在播放的视频
 */
- (void)pausePreview;

/**
 *  停止预览
 *
 */
- (void)stopPreView;

/**
 *  开始处理视频，异步任务
 */
- (void)startProcessVideo;

/**
 *  取消任务, 暂不支持
 */
- (void)cancel;

/**
 *  ks3 上传参数
 *
 *  @param params 参数字典
 *       包括下面的key
 *           KSYUploadBucketName 必填
 *           KSYUploadObjKey     必填
 *           KSYUploadDomain     可选
 *  @param uploadParamblock  'KSYGetUploadParamBlock(NSDictionary *params, KSYUploadWithTokenBlock block)'
            1.params回调一组参数(包括HttpMethod、ContentType、Resource、Headers、ContentMd5)，客户使用这些参数从自己的服务器计算ks3上传的token及Date信息，关于block
            2.uploadParamblock参数的第二个参数也是一个block，用于将客户设置token及Date
 *  更具体的参考KSYDefines.h中的定义
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
 *  设置该delegate,以便接收内部回调
 */
@property (nonatomic, weak)id<KSYMediaEditorDelegate> delegate;

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

@required
/**
 *  上传ks3完成
 */
- (void)onKS3UploadFinish:(NSString *)path;

@optional

/**
 *  媒体文件处理进度
 *  [0.0f - 1.0f]
 *  @param value 进度
 *  @warning not support yet, will support in the future
 */
- (void)onComposeProgressChanged:(float)value;

/**
 *  媒体文件处理完成触发
 */
- (void)onComposeFinish:(NSString *)path;


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



