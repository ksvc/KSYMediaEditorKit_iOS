//
//  KSYMETimeLineItem.h
//  KSYMediaEditorKit
//
//  Created by iVermisseDich on 2017/8/3.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KSYMETimeLineItemType){
    KSYMETimeLineItemTypeDecal = 0,
    KSYMETimeLineItemTypeDyImage
//    KSYMETimeLineItemTypeFilter,
//    KSYMETimeLineItemTypeMV,
//    KSYMETimeLineItemTypeBgm,
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
 * DyImage
 */
@interface KSYMETimeLineDyImageItem : KSYMETimeLineItem
// dynamic image资源路径（支持APNG）
@property (nonatomic, copy) NSString *resource;

@end

/**

// bgm
@interface KSYMETimeLineBgmModel : KSYMETimeLineItem
// 资源路径
@property (nonatomic, assign) NSString *resourcePath;
@end

// mv
@interface KSYMETimeLineMVModel : KSYMETimeLineItem
// mv 资源路径
@property (nonatomic, assign) NSString *resourcePath;
@end



// filter (filter 请提前删除input和target)
@interface KSYMETimeLineFilterModel : KSYMETimeLineItem
// Filter 对象
@property (nonatomic, weak) GPUImageOutput<GPUImageInput> *filter;
@end
 
*/
