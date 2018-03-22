//
//  KSYMETimeLineItem.h
//  KSYMediaEditorKit
//
//  Created by iVermisseDich on 2017/8/3.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>
#import "KSYMEDeps.h"

typedef NS_ENUM(NSInteger, KSYMETimeLineItemType){
    KSYMETimeLineItemTypeDecal = 0,
    KSYMETimeLineItemTypeDyImage,
    KSYMETimeLineItemTypeMedia,
    KSYMETimeLineItemTypeBGM,
    KSYMETimeLineItemTypeMV,
    KSYMETimeLineItemTypeFilter,
    KSYMETimeLineItemTypeTransition
};

/**
 * timeline item 基础模型（适用于贴纸、字幕）
 */
@interface KSYMETimeLineItem : NSObject
// 展示贴纸的View
@property (nonatomic, weak) id target;
// 特效类型
@property (nonatomic, assign) KSYMETimeLineItemType effectType;
// 开始时间
@property (nonatomic, assign) CGFloat startTime;
// 结束时间
@property (nonatomic, assign) CGFloat endTime;
@end

/**
 DyImage
 */
@interface KSYMETimeLineDyImageItem : KSYMETimeLineItem
// dynamic image资源路径（支持APNG、Gif）
@property (nonatomic, copy) NSString *resource;

@end

#pragma mark - KSYMETimeLineBgmItem
/**
 media item model
 video / audio
 if resource media has video track will trigger
 
 - media item not support loop, only bgm item support loop
 */
@interface KSYMETimeLineMediaItem : KSYMETimeLineItem
// resource 路径
@property (nonatomic, copy) NSURL *resource;

///// Video Track /////

///// Audio Track /////

@end
/**
 bgm item model
 
 - bgm item will ignore playRate and will not apply to the composition
 - apply playRate for audio can use KSYMETimeLineMediaItem (type:KSYMETimeLineItemTypeMedia)
 */
@interface KSYMETimeLineBGMItem : KSYMETimeLineItem
// auto loop, Default is NO
@property (nonatomic, assign) BOOL loop;
/**
 volume of audio track
 
 - can only take effects for media which has audio track
 - value range is [0, 2.0], default is 1.0
 
 @warning if output sound type is mono, leftVolume is main Volume
 */
@property (nonatomic, assign) float leftVolume;
/**
 volume of audio track
 
 - can only take effects for media which has audio track
 - value range is [0, 2.0], default is 1.0
 
 @warning if output sound type is mono, rightVolume will not take effects
 */
@property (nonatomic, assign) float rightVolume;
@end

#pragma mark - KSYMEFilterItem
// custom filter item model
@interface KSYMETimeLineFilterItem : KSYMETimeLineItem
// filter identity
@property (nonatomic, copy) NSString *name;
/** filter ID 
 indicate the current times the filter will be used on timeline
 
 0 means the first time to use on MV theme’s timeline or editor's preview timeline
 1 means the second time to use on MV theme’s timeline or editor's preview timeline
 
 - 外置滤镜 为自定义ID 需要用户自行设定，timeline上递增即可
 - 内置滤镜 支持多种类型的内部滤镜，具体请参考 KSYMEBuiltInFilter, 滤镜参数在 params 字段中设定
 eg.
 */
@property (nonatomic, assign) NSInteger filterID;
// custom vertex shader, nullable
@property (nonatomic, copy) NSString *vertex;
// custom fragment shader, nullable
@property (nonatomic, copy) NSString *fragment;
/**
 filter params, nullable
 具体参考 https://github.com/ksvc/KSYMediaEditorMV/wiki/keyDetail fid字段
 
 内置滤镜 KSYMEBuiltInFilter_SuperEffect、KSYMEBuiltInFilter_TimeEffect 需要指定子类型，
 子类型参考 KSYSEType (特效滤镜)、KSYTEType（时间特效滤镜）。
 
 示例: @{ @"idx" : @(KSYSEType_ZOOM); }
 */
@property (nonatomic) NSDictionary *params;
@end

#pragma mark - KSYMETimeLineMVItem
/**
 MV theme model
 MV support built-in beauty filter see: KSYMEBuiltInFilter
 */
@interface KSYMETimeLineMVItem : KSYMETimeLineItem
// bgm item
@property (nonatomic, strong) KSYMETimeLineMediaItem *audioItem;
// video item
@property (nonatomic, strong) KSYMETimeLineMediaItem *videoItem;
// filter item list
@property (nonatomic, strong) NSArray <KSYMETimeLineFilterItem*> *filters;
// loop the specified mv theme or play just once
@property (nonatomic, assign) BOOL loop;
// animations 字典 
@property (nonatomic, strong) NSDictionary *animations;
@end

#pragma mark - KSYMETransFilterItem
@interface KSYMETimeLineTransItem : KSYMETimeLineItem
// transition srcAsset
@property (nonatomic, strong) AVAsset *fromAsset;
// transition dstAsset
@property (nonatomic, strong) AVAsset *toAsset;

@end
