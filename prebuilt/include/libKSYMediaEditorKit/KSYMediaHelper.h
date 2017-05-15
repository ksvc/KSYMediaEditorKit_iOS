//
//  KSYMediaHelper.h
//  KSYMediaEditorKit
//
//  Created by 张俊 on 17/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//
#import "KSYDefines.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoMetaInfo : NSObject

@property(nonatomic, assign)CMTime duration;

@property(nonatomic, assign)CGSize naturalSize;

@property(nonatomic, assign)int degree;

@end

@interface KSYMediaHelper : NSObject
/**
 *  获取本地视频信息
 *
 *  @param path 本地视频地址
 *
 *  @return 视频信息
 */
+ (VideoMetaInfo *)videoMetaFrom:(NSString *)path;

/**
 通过transform 获取视频rotate信息
 */
+ (NSInteger)getVideoAngleWithTransform:(CGAffineTransform)transform;

/**
 同步截图接口

 @param path 要截取的视频路径
 @param atTime 截取时间点
 @param attr 截图属性，
    暂时支持的属性是指定缩略图的高，内部会依据视频尺寸作等比例scale，指定的高必须要小于视频的高
 @param actualTime 真实的截取时间点
 @param outError 错误信息
 @return 截取到的图像
 */
+ (CGImageRef)thumbnailForVideo:(NSString *)path
                         atTime:(CMTime)atTime
                           attr:(NSDictionary *)attr
                     actualTime:(CMTime *)actualTime
                          error:(NSError **)outError;

/**
 异步截图接口
 
 @param path    视频路径,用户需保证视频存在
 @param atTimes 请求截图的数组，比如
    NSArray *times = @[[NSValue valueWithCMTime:kCMTimeZero], [NSValue valueWithCMTime:CMTimeXX]]
 @param attr 截图属性，比如指定截图的高
    暂时支持的属性是指定缩略图的高，内部会依据视频尺寸作等比例scale，指定的高必须要小于视频的高
 @param handler 截图异步回调函数
 */
+ (void)thumbnailForVideo:(NSString *)path
                  atTimes:(NSArray<NSValue *> *)atTimes
                     attr:(NSDictionary *)attr
        completionHandler:(KSYThumbnailGenHandler)handler;


@end
