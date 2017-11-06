//
//  KSYTransitionsModel.h
//  demo
//
//  Created by sunyazhou on 2017/10/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libksygpulive/KSYTransitionFilter.h>
typedef NS_ENUM(NSUInteger, KSYTransCellType){
    KSYTransCellTypeVideo = 0, //cell视频
    KSYTransCellTypeTrans = 1  //cell转场
    
};

@interface KSYTransModel : NSObject
@property (nonatomic, strong) id               asset;
@property (nonatomic, assign) BOOL             isSelected;
@property (nonatomic, assign) KSYTransCellType type;//UI上显示的 cell 类型
@property (nonatomic, assign) KSYTransitionType   transitionType; //标识当前的转场是哪个转场
@end
