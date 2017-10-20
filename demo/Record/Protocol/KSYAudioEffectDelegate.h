//
//  KSYAudioEffectDelegate.h
//  demo
//
//  Created by sunyazhou on 2017/7/12.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSYBGMusicView;
@protocol KSYAudioEffectDelegate <NSObject>

@optional
/**
 处理音效的代理方法
 
 @param type 音效类型
 @param value 变调级别
 */
- (void)audioEffectType:(KSYMEAudioEffectType)type andValue:(NSInteger)value;
@end
