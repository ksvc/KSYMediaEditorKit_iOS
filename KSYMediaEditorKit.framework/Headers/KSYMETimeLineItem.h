//
//  KSYMETimeLineItem.h
//  KSYMediaEditorKit
//
//  Created by iVermisseDich on 2017/8/3.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KSYMETimeLineItemType){
    KSYMETimeLineItemTypeDecal
//    KSYMEEffectTypeFilter,
//    KSYMEEffectTypeMV,
//    KSYMEEffectTypeBgm,
//    KSYMEEffectTypeDyImage
};

@interface KSYMETimeLineItem : NSObject

@property (nonatomic, weak) id target;
// 特效类型
@property (nonatomic, assign) KSYMETimeLineItemType effectType;
// 开始时间
@property (nonatomic, assign) CGFloat startTime;
// 结束时间
@property (nonatomic, assign) CGFloat endTime;

@end

/**

// bgm
@interface KSYMETimeLineBgmModel : KSYMETimeLineItem
// 资源路径
@property (nonatomic, assign) NSString *resourcePath;
@end

// mv
@interface KSYMETimeLineBgmModel : KSYMETimeLineItem
// mv 资源路径
@property (nonatomic, assign) NSString *resourcePath;
@end

// DyImage
@interface KSYMETimeLineBgmModel : KSYMETimeLineItem
// dynamic image资源路径
@property (nonatomic, assign) NSArray *imgArray;
@end

// filter (filter 请提前删除input和target)
@interface KSYMETimeLineBgmModel : KSYMETimeLineItem
// Filter 对象
@property (nonatomic, weak) GPUImageOutput<GPUImageInput> *filter;
@end
 
*/
