//
//  KSYWaterMarkCfg.h
//  KSYMediaEditorKit
//
//  Created by 张俊 on 31/03/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface KSYWaterMarkCfg : NSObject

@property(nonatomic, assign, getter=isShow) BOOL show;
/**
 *  水印图片
 */
@property(nonatomic, strong) UIImage *waterMarkMask;

/**
 *  水印位置
 */
@property (nonatomic, assign) CGRect logoRect;


@property (nonatomic, assign) CGFloat alpha;



@end
