//
//  KSYMediaHelper.h
//  KSYMediaEditorKit
//
//  Created by 张俊 on 17/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//
#import "KSYDefines.h"
#import <AVFoundation/AVFoundation.h>

@interface MediaMetaInfo : NSObject

//公共字段
@property(nonatomic, assign)CMTime duration;

//视频相关
@property(nonatomic, assign)CGSize naturalSize;
@property(nonatomic, assign)int degree;
    
//音频相关（暂未提供）

@end

@interface KSYMediaHelper : NSObject
/**
 @abstract 获取本地视频信息
 
 @param path 本地视频地址
 @return 视频信息
 */
+ (MediaMetaInfo *)videoMetaFrom:(NSURL *)path;

    
/**
 @abstract 获取本地音频信息

 @param url 本地音频文件路径
 @return 音频文件信息
 */
+ (MediaMetaInfo *)audioMetaFrom:(NSURL *)url;

/**
 通过transform 获取视频rotate信息
 */
+ (NSInteger)getVideoAngleWithTransform:(CGAffineTransform)transform;

/**
 @abstract 从 CVPixelBufferRef 中获取图片

 @param videoBuffer pixel buffer
 @return image
 */
+ (UIImage *)getImgFromPixelBuffer:(CVPixelBufferRef)videoBuffer;

/**
 @abstract 同步截图接口

 @param path 要截取的视频路径
 @param atTime 截取时间点
 @param attr 截图属性，暂时支持的属性是指定缩略图的高，内部会依据视频尺寸作等比例scale，指定的高必须要小于视频的高
 @param actualTime 真实的截取时间点
 @param outError 错误信息
 @return 截取到的图像
 */
+ (CGImageRef)thumbnailForVideo:(NSURL *)path
                         atTime:(CMTime)atTime
                           attr:(NSDictionary *)attr
                     actualTime:(CMTime *)actualTime
                          error:(NSError **)outError;

/**
 @abstract 异步截图接口
 
 @param path    视频路径,用户需保证视频存在
 @param atTimes 请求截图的数组，比如
    NSArray *times = @[[NSValue valueWithCMTime:kCMTimeZero], [NSValue valueWithCMTime:CMTimeXX]]
 @param attr 截图属性，比如指定截图的高
    暂时支持的属性是指定缩略图的高，内部会依据视频尺寸作等比例scale，指定的高必须要小于视频的高，参考KSYDefines.h
 @param handler 截图异步回调函数
 */
+ (void)thumbnailForVideo:(NSURL *)path
                  atTimes:(NSArray<NSValue *> *)atTimes
                     attr:(NSDictionary *)attr
        completionHandler:(KSYThumbnailGenHandler)handler;


@end
