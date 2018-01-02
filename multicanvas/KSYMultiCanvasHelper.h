//
//  KSYMultiCanvas.h
//  multicanvas
//
//  Created by sunyazhou on 2017/12/15.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KSYMCChannelType) {
    KSYMCChannelTypeLeft = 0,
    KSYMCChannelTypeRight = 1
};

@interface KSYMultiCanvasHelper : NSObject

+ (CGFloat)calculateVolume:(KSYMCChannelType)type
                  panValue:(CGFloat)pan
                    volume:(CGFloat)volume;

@end
