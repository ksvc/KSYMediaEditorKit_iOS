//
//  KSYDecalView.m
//  demo
//
//  Created by iVermisseDich on 2017/5/19.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYDecalView.h"
#define kDecalViewBtnLength 16
@interface KSYDecalView ()

@end

@implementation KSYDecalView

- (instancetype)initWithImage:(UIImage *)image{
    if (self = [super initWithImage:image]) {
        self.userInteractionEnabled = YES;
        _oriScale = 1.0;
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews{
//    [super layoutSubviews];
    _dragBtn.center = CGPointMake(self.frame.size.width, self.frame.size.height);
    _closeBtn.center = CGPointMake(self.frame.size.width, 0);
}

- (void)setupUI{
    _dragBtn = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"decal_rotate"]];
    _dragBtn.userInteractionEnabled = YES;
    [self addSubview:_dragBtn];
    
    _closeBtn = [[UIButton alloc] init];
    [_closeBtn setImage:[UIImage imageNamed:@"decal_delete"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeBtn];

    _dragBtn.frame = CGRectMake(0, 0, kDecalViewBtnLength, kDecalViewBtnLength);
    _closeBtn.frame = CGRectMake(0, 0, kDecalViewBtnLength, kDecalViewBtnLength);
}

- (void)close:(id)sender{
    [self removeFromSuperview];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (self.alpha > 0.1 && !self.clipsToBounds) {
        for (UIView *subView in @[self.dragBtn, self.closeBtn]) {
            CGPoint subPoint = [self convertPoint:point toView:subView];
            UIView *resultView = [subView hitTest:subPoint withEvent:event];
            if (resultView) {
                return resultView;
            }
        }
    }
    
    return [super hitTest:point withEvent:event];
}

- (void)setSelect:(BOOL)select{
    _select = select;
    if (select) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.closeBtn.hidden = NO;
        self.dragBtn.hidden = NO;
    }else{
        self.layer.borderWidth = 0;
        self.closeBtn.hidden = YES;
        self.dragBtn.hidden = YES;
    }
}

- (CGAffineTransform)currentTransform{
    return self.transform;
}

@end
