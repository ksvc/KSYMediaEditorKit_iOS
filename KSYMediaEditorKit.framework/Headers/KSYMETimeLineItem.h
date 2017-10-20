//
//  KSYMETimeLineItem.h
//  KSYMediaEditorKit
//
//  Created by iVermisseDich on 2017/8/3.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>

typedef NS_ENUM(NSInteger, KSYMETimeLineItemType){
    KSYMETimeLineItemTypeDecal = 0,
    KSYMETimeLineItemTypeDyImage,
    KSYMETimeLineItemTypeMV,
    KSYMETimeLineItemTypeFilter,
    KSYMETimeLineItemTypeMedia
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
 */
@interface KSYMETimeLineMediaItem : KSYMETimeLineItem
// resource 路径
@property (nonatomic, copy) NSString *resource;
@end

#pragma mark - KSYMEMVFilterItem
// custom filter item model
@interface KSYMETimeLineFilterItem : KSYMETimeLineItem
// filter identity
@property (nonatomic, copy) NSString *name;
/** filter ID 
 indicate the current times the filter will be used on timeline
 
 0 means the first time to use on MV theme’s timeline or editor's preview timeline
 1 means the second time to use on MV theme’s timeline or editor's preview timeline
 eg.
 */
@property (nonatomic, assign) NSInteger filterID;
// custom vertex shader
@property (nonatomic, copy) NSString *vertex;
// custom fragment shader
@property (nonatomic, copy) NSString *fragment;
// params
@property (nonatomic) NSDictionary *params;
@end



#pragma mark - KSYMETimeLineMVItem
/**
 MV theme model
 MV support built-in beauty filter see: KSYMEMVBuiltInFilter
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
