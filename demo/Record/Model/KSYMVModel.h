//
//  KSYMVModel.h
//  demo
//
//  Created by sunyazhou on 2017/9/20.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSYMVModel : NSObject
@property (nonatomic, copy) NSString *mvName;   //显示名称
@property (nonatomic, copy) NSString *bgmImage; //图片
@property (nonatomic, copy) NSString *mvResName;//资源包名称
@property (nonatomic, assign) BOOL isSelected;
@end
