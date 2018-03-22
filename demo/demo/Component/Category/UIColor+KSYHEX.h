//
//  UIColor+KSYHEX.h
//  demo
//
//  Created by sunyazhou on 2017/8/30.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (KSYHEX)
+ (UIColor *)ksy_colorWithHex:(UInt32)hex;
+ (UIColor *)ksy_colorWithHex:(UInt32)hex andAlpha:(CGFloat)alpha;
+ (UIColor *)ksy_colorWithHexString:(NSString *)hexString;
- (NSString *)ksy_HEXString;
///值不需要除以255.0
+ (UIColor *)ksy_colorWithWholeRed:(CGFloat)red
                            green:(CGFloat)green
                             blue:(CGFloat)blue
                            alpha:(CGFloat)alpha;
///值不需要除以255.0
+ (UIColor *)ksy_colorWithWholeRed:(CGFloat)red
                            green:(CGFloat)green
                             blue:(CGFloat)blue;
@end
