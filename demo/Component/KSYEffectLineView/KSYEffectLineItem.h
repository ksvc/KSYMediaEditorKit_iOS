//
//  KSYEffectLineItem.h
//  demo
//
//  Created by sunyazhou on 2017/12/21.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSYEffectLineItem : NSObject

@property (nonatomic, strong  ) UIImage *image;
@property (nonatomic, readonly) CMTime  time;

+ (instancetype)thumbnailWithImage:(UIImage *)image
                              time:(CMTime)time;
@end
