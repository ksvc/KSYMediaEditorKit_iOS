//
//  KSYMETransitionEditor.h
//  KSYMediaEditorKit
//
//  Created by iVermisseDich on 2017/10/16.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "KSYMEDeps.h"

@interface KSYMETransitionEditor : NSObject

/**
 视频转视频(默认不带转场效果)
 
 @param imageList 视频地址列表
 @return transition editor instnace
 */
- (instancetype)initWithVideoList:(NSArray<NSURL *>*)videoList;

/**
 @abstract
     setVideoList will update current preview video list
 */
@property (nonatomic, strong) NSArray<NSURL *>*videoList;

/**
 @abstract
     将预览视图添加至指定的view上并开始预览
 @param view preview 视图将要被添加到的父视图, 预览窗口将使用父视图作为大小
 @param loop 是否循环播放
 
 @discussion
     默认情况下会loop播放所有视频列表中的视频
 */
- (void)startPreviewOn:(UIView *)view loop:(BOOL)loop;

/**
 @abstract
     停止预览
 */
- (void)stopPreview;

/**
 @abstract
     获取预览视图
 @discussion
     预览视图默认参考父视图大小及位置，可以通过设置previewView的frame进行修改
 */
- (KSYGPUView *)previewView;

/*
 @abstract
     增加转场(用于预览)
 
 @param idx             对应的专场index，例如 三个视频可添加4个转场，请参考discussion中示意图
 @param type            转场类型，详见 KSYTransitionType， 默认为 KSYTransitionTypeNone
 @param overlapType     转场重叠视频类型，详见 KSYOverlapType。默认为 KSYOverlapType_BothVideo
 @param duration        转场视频重叠时间，默认为1s
 
 @discussion
     如下，三个视频轨道可以添加4个转场效果，idx对应从 0 - 3
     ----track0---- ----track1---- ----track2----
     --           ---            ---           --
     |             |              |             |
     开场         转 场           转 场         收场
 
     视频的收场效果，建议使用淡出、闪黑等转场，不建议其他类型，仅供参考
     转场时，前后视频可以重叠，也可以不重叠，通过设置overlapType设置重叠的类型
     通过设置overlapFrames设置重叠视频帧数
 */
- (void)setTransitionWithIdx:(NSInteger)idx
                        type:(KSYTransitionType)transType
                 overlapType:(KSYOverlapType)overlapType
             overlapDuration:(CGFloat)duration;

/*
 @abstract
     单/多视频 添加转场效果
 
 @param url 输出路径
 @param resolution 输出分辨率
 @param vb video bitrate
 @param ab audio bitrate
 @param progress 进度回调
 @param error 错误码及错误信息回调
 @param finish 完成回调
 @discussion
     please stop preview when start concat
 */
- (void)concatVideosWithOutUrl:(NSURL *)url
                    resolution:(CGSize)resolution
                  videoBitrate:(NSInteger)vb
                  audioBitrate:(NSInteger)ab
                    progressCB:(void(^)(CGFloat progress))progress
                       errorCB:(void(^)(int errorCode, NSString *errInfo))error
                      finishCB:(void(^)(NSURL *outURL))finish;


#pragma mark - Image2Video

/**
 图片转视频(默认不带转场效果)
 
 @param imageList 图片地址列表
 @return transition editor instnace
 */
- (instancetype)initWithImageList:(NSArray<UIImage *>*)imageList;

/**
 设置图片展示时间、变化区域，输出分辨率等信息

 @param duration 持续时间，默认为 4s
 @param idx imageList 中图片对应的index，取值范围 [0, imageList.count -1]
 @param fromRegion 开始展示区域，默认为 (0, 0, 1, 1)
 @param toRegion 最终展示区域, 默认为 (0, 0, 1, 1)
 @param outputSize 输出分辨率，默认与原图片分辨率保持一致
 
 @discussion
     1. 在duration 时间内，图片显示区域会从fromRegion 渐变至 toRegion
 
     2. fromRegion 与 toRegion 格式为 CGRect (x, y, w, h)，component 范围为 0.0 - 1.0
     - fromeRegion 与toRegion 的x、y 不同时，将会产生平移效果
     - fromeRegion 与toRegion 的w、h 不同时，将会产生缩放效果
     - x + w > 1 或 y + h > 1 时，x < 0 或 y < 0 时，将会有部分黑色区域
     - x + w < 0 或 y + h < 0 时，将会输出全黑的图片
 
     3. 请保证outputSize 的宽高比与region 表示的图片区域的宽高比一致，否则会出现拉伸
       即 region.w * image.width / region.h * image.height 与
       outputSize.width / outputSize.height 相等
 
     4. 输出视频总时长为所有图片的duration 之和并减去所有转场的重叠时间
 */
- (void)setImageDuration:(CMTime)duration
               withIndex:(NSInteger)idx
              fromRegion:(CGRect)fromRegion
                toRegion:(CGRect)toRegion
              outputSize:(CGSize)outputSize;


/**
 图片转视频

 @param outURL 输出路径，默认路径为 Documents/img2video_xxx.mp4
 @param fps frame rate
 @param resolution 输出视频分辨率
 @param vb video bitrate
 @param ab audio bitrate
 @param progress 进度回调
 @param error 合成出错回调
 @param finish 完成回调
 
 @discussion
     输出视频总时长为所有图片的duration 之和并减去所有转场的重叠时间
 */
- (void)concatImagesWithOutputUrl:(NSURL *)outURL
                        frameRate:(NSInteger)fps
                       resolution:(CGSize)resolution
                     videoBitrate:(NSInteger)vb
                     audioBitrate:(NSInteger)ab
                       progressCB:(void(^)(CGFloat progress))progress
                          errorCB:(void(^)(int errorCode, NSString *errInfo))error
                         finishCB:(void(^)(NSURL *outURL))finish;
@end
