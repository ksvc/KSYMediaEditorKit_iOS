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
    for (UIView *view in self.subviews) {
        CGPoint subPoint = [view convertPoint:point fromView:self];
        UIView *resultView = [view hitTest:subPoint withEvent:event];
        if (resultView) {
            return resultView;
        }
    }
    return [super hitTest:point withEvent:event];
}

@end
