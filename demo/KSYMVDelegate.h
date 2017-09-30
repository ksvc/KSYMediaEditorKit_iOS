//
//  KSYMVDelegate.h
//  demo
//
//  Created by sunyazhou on 2017/9/20.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol KSYMVDelegate <NSObject>

@optional


/**
 当前选择的 MV 资源包名称

 @param mvResName 资源包名称(如果 nil 则表示选择的是 去掉 MV 效果)
 */
- (void)mvDidSelectedMVPathName:(NSString *)mvResName;
@end
