//
//  KSYBGMusicViewDelegate.h
//  demo
//
//  Created by sunyazhou on 2017/7/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KSYBGMusicViewDelegate <NSObject>
@optional

/**
 背景音乐的代理方法
 
 @param view 背景音乐的视图
 @param filePath 音乐本地路径
 */
- (void)bgMusicView:(UIView *)view
       songFilePath:(NSString *)filePath;


/**
 麦克风音量和背景音乐的音量 代理方法
 
 @param view 背景音乐的视图
 @param type 音量类型
 @param value 变化的value
 */
- (void)bgMusicView:(UIView *)view
    audioVolumnType:(KSYMEAudioVolumnType)type
           andValue:(CGFloat)value;
@end
