//
//  KSYMultiCanvasDefines.h
//  multicanvas
//
//  Created by sunyazhou on 2017/11/24.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#ifndef KSYMultiCanvasDefines_h
#define KSYMultiCanvasDefines_h

// size
#define kSCREEN_SIZE [[UIScreen mainScreen] bounds].size
#define kScreenSizeHeight (kSCREEN_SIZE.height)
#define kScreenSizeWidth (kSCREEN_SIZE.width)
#define kScreenMaxLength (MAX(kScreenSizeWidth, kScreenSizeHeight))
#define kScreenMinLength (MIN(kScreenSizeWidth, kScreenSizeHeight))

#define IS_IPHONEX (([[UIScreen mainScreen] bounds].size.height-812)?NO:YES)

// safe_main_thread
#define dispatch_async_main_safe(block) \
if ([NSThread isMainThread]) \
block \
else \
dispatch_async(dispatch_get_main_queue(), ^{block});


#define WeakSelf(VC)  __weak VC *weakSelf = self

#define UIColorFromRGB(R,G,B)  [UIColor colorWithRed:(R * 1.0) / 255.0 green:(G * 1.0) / 255.0 blue:(B * 1.0) / 255.0 alpha:1.0]
#define rgba(R,G,B,A)  [UIColor colorWithRed:(R * 1.0) / 255.0 green:(G * 1.0) / 255.0 blue:(B * 1.0) / 255.0 alpha:A]

#import "KSYMultiCanvasHelper.h"

#endif /* KSYMultiCanvasDefines_h */
