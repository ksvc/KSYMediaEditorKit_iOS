//
//  SlideInPresentationController.m
//  Nemo
//
//  Created by sunyazhou on 2017/6/9.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideInPresentationController.h"


@interface SlideInPresentationController ()

@property(nonatomic, assign)PresentationDirection direction;
@property(nonatomic, strong)UIView *dimmingView; //遮盖视图
@end

@implementation SlideInPresentationController


#pragma mark -
#pragma mark - public methods 公有方法
- (instancetype)initWithPresentedViewController:(UIViewController *)presented  presentingViewController:(UIViewController *)presenting andDirection:(PresentationDirection)direction
{
    self = [super initWithPresentedViewController:presented presentingViewController:presenting];
    if (self) {
        self.direction = direction;
    }
    return self;
}

#pragma mark -
#pragma mark - private methods 私有方法
- (void)setupDimmingView{
    if (self.dimmingView == nil) {
        self.dimmingView = [[UIView alloc] init];
        self.dimmingView.translatesAutoresizingMaskIntoConstraints = NO;
        self.dimmingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        self.dimmingView.alpha = 0.0;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self.dimmingView addGestureRecognizer:tapGesture];
    }
}


#pragma mark -
#pragma mark - Override 复写方法
- (void)presentationTransitionWillBegin{
    if (self.showDimView) {
        [self.containerView insertSubview:self.dimmingView atIndex:0];
        
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[dimmingView]|" options:0 metrics:nil views:@{@"dimmingView":self.dimmingView}]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[dimmingView]|" options:0 metrics:nil views:@{@"dimmingView":self.dimmingView}]];
        
        id <UIViewControllerTransitionCoordinator> coordinator = self.presentedViewController.transitionCoordinator;
        if (coordinator == nil) {
            self.dimmingView.alpha = 1.0;
            return;
        }
        
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.dimmingView.alpha = 1.0;
        } completion:nil];
    }
}

- (void)dismissalTransitionWillBegin{
    if (self.showDimView) {
        id <UIViewControllerTransitionCoordinator> coordinator = self.presentedViewController.transitionCoordinator;
        if (coordinator == nil) {
            self.dimmingView.alpha = 0.0;
            return;
        }
        
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.dimmingView.alpha = 0.0;
        } completion:nil];
    }
}

- (void)containerViewWillLayoutSubviews{
    if (self.presentedView) {
        self.presentedView.frame = [self frameOfPresentedViewInContainerView];
    }
}

- (CGSize)sizeForChildContentContainer:(id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    if (self.containerViewSizeToFit) {
        return parentSize;
    }
    switch (self.direction) {
        case PresentationDirectionLeft:{
            return CGSizeMake(parentSize.width*(self.sliderRate), parentSize.height);
        }
            break;
        case PresentationDirectionRight:{
            return CGSizeMake(parentSize.width*(self.sliderRate), parentSize.height);
        }
            break;
        case PresentationDirectionTop:{
            return CGSizeMake(parentSize.width, parentSize.height*(self.sliderRate));
        }
            break;
        case PresentationDirectionBottom:{
            return CGSizeMake(parentSize.width, parentSize.height*(self.sliderRate));
        }
            break;
        default:
            return CGSizeZero;
            break;
    }
    return CGSizeZero;
}

#pragma mark -
#pragma mark - getters and setters 设置器和访问器
- (CGRect)frameOfPresentedViewInContainerView{
    if (self.containerViewSizeToFit) {
        CGFloat kSlideScreenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat kSlideScreenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat deltaY = kSlideScreenHeight *(1 - self.sliderRate);
        self.containerView.frame = CGRectMake(0, deltaY, kSlideScreenWidth, kSlideScreenHeight * self.sliderRate);
        return self.containerView.bounds;
        
    }
    CGRect frame = CGRectZero;
    frame.size = [self sizeForChildContentContainer:self.presentedViewController withParentContainerSize:self.containerView.bounds.size];
    if (self.direction == PresentationDirectionRight) {
        frame.origin.x = self.containerView.frame.size.width*(1-(self.sliderRate));
    } else if (self.direction == PresentationDirectionBottom) {
        frame.origin.y = self.containerView.frame.size.height*(1-(self.sliderRate));
    } else {
        frame.origin = CGPointZero;
    }
    return frame;
}

- (void)setSliderRate:(CGFloat)sliderRate {
    CGFloat limitRate = sliderRate > 1? fmin(sliderRate, 1.0):fmax(0, sliderRate);
    _sliderRate = limitRate;
}


- (void)setShowDimView:(BOOL)showDimView {
    _showDimView = showDimView;
    if (showDimView) {
        [self setupDimmingView];
    } else {
        [self.dimmingView removeFromSuperview];
        self.dimmingView = nil;
    }
}

#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
- (void)handleTap:(UIGestureRecognizer *)tapGesture {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
