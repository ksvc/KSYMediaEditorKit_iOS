//
//  UIView+XIB.m
//  demo
//
//  Created by sunyazhou on 2017/6/16.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "UIView+XIB.h"

@implementation UIView (XIB)
+ (instancetype)viewFromXIB{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}
@end
