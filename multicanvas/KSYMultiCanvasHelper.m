//
//  KSYMultiCanvasHelper.m
//  multicanvas
//
//  Created by sunyazhou on 2017/12/15.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYMultiCanvasHelper.h"
#import <math.h>

@implementation KSYMultiCanvasHelper

+ (CGFloat)calculateVolume:(KSYMCChannelType)type
                  panValue:(CGFloat)pan
                    volume:(CGFloat)volume{
    if (type == KSYMCChannelTypeLeft) {
        CGFloat leftVolumn = sqrt(2) * cos((1 + pan)*M_PI_4) *volume;
        return leftVolumn;
    } else if (type == KSYMCChannelTypeRight) {
        CGFloat rightVolumn = sqrt(2) * sin((1 + pan)*M_PI_4) *volume;
        return rightVolumn;
    }
    
    return 0;
}
@end
