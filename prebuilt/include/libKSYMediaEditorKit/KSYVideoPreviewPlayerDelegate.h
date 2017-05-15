//
//  KSYVideoPreviewPlayerDelegate.h
//  KSYMediaEditorKit
//
//  Created by 张俊 on 08/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

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
typedef NS_ENUM(NSInteger, KSYVideoPreviewPlayerStatus){
    KSYPreviewPlayerIdle,
    KSYPreviewPlayerPlay,
    KSYPreviewPlayerPause,
    KSYPreviewPlayerStop,
};

@protocol KSYVideoPreviewPlayerDelegate <NSObject>

- (void)onPlayStatusChanged:(KSYVideoPreviewPlayerStatus)status;

/**
 播放进度
 
 @param time 要播放的范围
 @param percent  该范围内已经播放的百分比
 */
- (void)onPlayProgressChanged:(CMTimeRange)time percent:(float)percent;

@end
