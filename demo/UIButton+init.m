//
//  UIButton+init.m
//  Nemo
//
//  Created by iVermisseDich on 16/11/23.
//  Copyright © 2016年 com.ksyun. All rights reserved.
//

#import "UIButton+init.h"

@implementation UIButton (init)

// 创建一个button
+ (UIButton *)buttonWithFrame:(CGRect)rect target:(id)target normal:(NSString *)image_nm highlited:(NSString *)image_hl selected:(NSString *)image_sel selector:(SEL)sel{
    // frame
    UIButton *btn = [[UIButton alloc] initWithFrame:rect];
    // target
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    // image
    [btn setImage:[UIImage imageNamed:image_nm] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:image_hl] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:image_sel] forState:UIControlStateSelected];
    [btn sizeToFit];
    return btn;
}

@end
