//
//  KSYBgMusicModel.h
//  demo
//
//  Created by sunyazhou on 2017/7/11.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSYBgMusicModel : NSObject
@property(nonatomic, copy) NSString *bgmName;
@property(nonatomic, copy) NSString *bgmImageName;
@property(nonatomic, copy) NSString *bgmPath;
@property(nonatomic, assign) BOOL isSelected;
@end
