//
//  KSYEffectLineItem.m
//  demo
//
//  Created by sunyazhou on 2017/12/21.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEffectLineItem.h"

@implementation KSYEffectLineItem
+ (instancetype)thumbnailWithImage:(UIImage *)image time:(CMTime)time {
    return [[self alloc] initWithImage:image time:time];
}

- (id)initWithImage:(UIImage *)image time:(CMTime)time {
    self = [super init];
    if (self) {
        _image = image;
        _time = time;
    }
    return self;
}
@end
