//
//  KSYMETransitionEditor.h
//  KSYMediaEditorKit
//
//  Created by iVermisseDich on 2017/10/16.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libksygpulive/libksygpufilter.h>
#import <libksygpulive/libksystreamerengine.h>

@interface KSYMETransitionEditor : NSObject

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
                    progressCB:(void(^)(int idx, CGFloat progress))progress
                       errorCB:(void(^)(int errorCode, NSString *errInfo))error
                      finishCB:(void(^)(NSURL *outURL))finish;

@end
