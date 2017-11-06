//
//  KSYAssetConcatInfo.h
//  KSYMediaEditorKit
//
//  Created by iVermisseDich on 2017/12/6.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KSYAssetType) {
    KSYAssetType_Video,     // 视频 (支持纯音频/无音频轨道/无视频轨道 的媒体文件)
    KSYAssetType_Image,     // 图片
    KSYAssetType_DyImg      // 动态图片（未开放）
};

@interface KSYAssetConcatInfo : NSObject

/**
 indicates type of the asset, default is KSYAssetType_Video
 */
@property (nonatomic, assign) KSYAssetType type;

/**
 video、image render region
 
 - can only take effects for video, Image and dyImg
 - format：(x,y,s,t),each component‘s value range is [0，1]，default is (0,0,0,0)
 */
@property (nonatomic, assign) CGRect renderRegion;

/**
 volume of audio track
 
 - can only take effects for audio or video(has audio track)
 - value range is [0, 1.0], default is 1.0 (0 ~ 1.0)
 */
@property (nonatomic, assign) float leftVolume;
/**
 volume of audio track
 
 - can only take effects for audio or video(has audio track)
 - value range is [0, 1.0], default is 1.0 (0 ~ 1.0)
 */
@property (nonatomic, assign) float rightVolume;

@end
