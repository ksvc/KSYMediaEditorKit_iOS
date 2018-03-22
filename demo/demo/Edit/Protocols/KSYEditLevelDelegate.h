//
//  KSYEditLevelDelegate.h
//  demo
//
//  Created by sunyazhou on 2017/7/18.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KSYEditLevelDelegate <NSObject>
@optional

- (void)editLevel:(NSInteger)index;

- (void)editTimeEffect:(NSInteger)index;
@end
