//
//  KSYFilterModel.h
//  demo
//
//  Created by sunyazhou on 2017/7/10.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSYFilterModel : NSObject
@property(nonatomic, copy) NSString *imageName;
@property(nonatomic, copy) NSString *filterName;
@property(nonatomic, assign) BOOL isSelected;
@end
