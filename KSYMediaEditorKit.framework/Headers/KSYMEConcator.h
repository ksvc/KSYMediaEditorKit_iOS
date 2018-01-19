//
//  KSYMEConcator.h
//  KSYMediaEditorKit
//
//  Created by iVermisseDich on 2017/7/5.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYDefines.h"

@protocol KSYMEConcatorDelegate;


/*********************************
 * KSYMEConcator 为多段视频拼接工具 *
 *********************************/

@interface KSYMEConcator : NSObject

/**
 @abstract KSYMEConcatorDelegate
 */
@property (nonatomic, weak) id<KSYMEConcatorDelegate> delegate;

/**
 @abstract 视频拼接中
 */
@property (nonatomic, assign, getter=isConcating) BOOL concating;
/**
 @abstract
     添加一个待处理的视频文件到编辑引擎（仅支持本地文件）
 
 @param         url 本地文件地址
 @return        添加状态
 
 @discussion
     1.目前仅支持添加一条视频，新添加的视频将会覆盖之前添加的视频
     2.频处理进行中时不能操作
 */
- (KSYStatusCode)addVideo:(NSURL *)url;

/**
 @abstract
     添加多个待处理的视频文件
 
 @param paths 文件列表, 无效文件不会被添加
 
 @discussion
     添加多段视频后可调用startConcat进行视频拼接
     1.目前对多段视频的操作，仅支持多段视频合成
     2.视频合成进行中时不可操作
     3.添加至videolist中，会覆盖videolist原有数据
 */
- (KSYStatusCode)addVideos:(NSArray<__kindof NSURL *> *)paths;

/**
 @abstract
     移除videolist中对应的URL视频（视频未删除）
 
 @param url 视频对应的路径
 @discussion 视频处理进行中时不能操作
 */
- (void)removeVideo:(NSURL *)url;

/**
 @abstract
     清空videolist中所有视频URL（视频未删除）
 @discussion
     视频处理进行中时不能操作
 */
- (void)removeAllVideos;

/**
 @abstract
     视频拼接(数量大于1才会进行拼接)
 
 @discussion
     调用addVideos添加视频之后，将添加的视频按先后顺序拼接为一个视频文件（源视频未删除）
     调用前必须使用addVideos:添加视频，或使用concatVideos:方法进行添加
     拼接进度会在onConcatProgressChanged:代理方法中回调
     拼接完成会在onConcatFinish:代理方法中回调
 */
- (void)startConcat;

/**
 @abstract
     视频拼接并添加至editor的videolist中
 
 @discussion
     将videoList中的视频按先后顺序拼接为一个视频文件。
     同时添加至videolist中，会覆盖videolist原有数据
     (建议使用同分辨率视频进行合成，)
 */
- (void)concatVideos:(NSArray <__kindof NSURL *>*)videoList;

/**
 @abstract
     视频拼接并添加至editor的videolist中

 @param videoList 视频列表
 @param mode 视频画面 resize 模式(裁剪、填充)
 @param ratio 视频画面输出宽高比（如: {9:16} {1:1} {3:4}等）
 
 @discussion
     根据导入视频的最低分辨率进行合成
     例如 ratio为{1:1}，输入视频的最低分辨率为720p，输出分辨率则为(720, 720)
         ratio为{3:4}，输入视频的最低分辨率为720p，输出分辨率则为(720, 960)
         ratio为{9:16}，输入视频的最低分辨率为720p，输出分辨率则为(720, 1280)
 */
//- (void)concatVideos:(NSArray<__kindof NSURL *> *)videoList resizeMode:(KSYMEResizeMode)mode resolutionRatio:(KSYMEResolutionRatio)ratio;

/**
 @abstract
 视频拼接并添加至editor的videolist中
 
 @param videoList 视频列表
 @param mode 视频画面 resize 模式(裁剪、填充)
 @param resolution 视频画面输出分辨率
 
 @discussion
    输出分辨率比导入视频的分辨率高会造成画面模糊
 */
- (void)concatVideos:(NSArray<__kindof NSURL *> *)videoList
          resizeMode:(KSYMEResizeMode)mode
          resolution:(CGSize)resolution
           outputURL:(NSURL *)outURL;

/**
 @abstract 取消合成
 */
- (void)cancelConcat;

@end


@protocol KSYMEConcatorDelegate <NSObject>

@required
/**
 @abstract KSYMediaEditor 内部的错误回调
 
 @param concator 合成器
 @param error    错误码
 @param extraStr extraStr
 */
- (void)onConcatError:(KSYMEConcator *)concator error:(KSYStatusCode)error  extraStr:(NSString*)extraStr;

@optional
/**
 @abstract 视频拼接
 */
- (void)onConcatFileIndex:(NSInteger)idx progressChanged:(float)value __attribute__((deprecated));

/**
 @abstract 视频拼接进度回调
 */
- (void)onConcatProgressChanged:(float)value;

/**
 @abstract 断点拍摄、多段导入视频拼接完成回调
 @param path 输出路径
 */
- (void)onConcatFinish:(NSURL *)path;

@end
