//
//  KSYFilterCfg.h
//  KSYMediaEditorKit
//
//  Created by 张俊 on 31/03/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KSYDefines.h"

@interface KSYFilterCfg : NSObject

-(instancetype)initWithFilter:(id)filter;

/**
 *  filter对象，如果使用内部美颜，则由sdk内部创建，
 *             如果使用GPUImage的美颜需要外部创建传入
 */
@property (nonatomic) id  filter;


/**
 *  内置美颜的类型
 */
@property (nonatomic, assign) KSYFilter filterKey;


//KSYBeautifyFaceFilter的调节参数，其他filter 暂不支持
//磨皮
@property(readwrite, nonatomic) CGFloat grindRatio;
//美白
@property(readwrite, nonatomic) CGFloat whitenRatio;
//红润
@property(readwrite, nonatomic) CGFloat ruddyRatio;

@end
