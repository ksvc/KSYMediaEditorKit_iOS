//
//  KSYDecalBGView.m
//  demo
//
//  Created by iVermisseDich on 2017/5/25.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYDecalBGView.h"

@implementation KSYDecalBGView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    __block UIView *responseView = nil;
    [self.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIView * _Nonnull subView, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint subPoint = [subView convertPoint:point fromView:self];
        UIView *resultView = [subView hitTest:subPoint withEvent:event];
        if (resultView) {
            responseView = resultView;
            *stop = YES;
        }
    }];
    return responseView ? responseView : [super hitTest:point withEvent:event];
}

@end
