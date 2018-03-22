//
//  SlideInPresentationAnimator.m
//  Nemo
//
//  Created by sunyazhou on 2017/6/9.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "SlideInPresentationAnimator.h"

@interface SlideInPresentationManager () 

@end

@implementation SlideInPresentationAnimator
- (instancetype)initWithDirection:(PresentationDirection)direction
                   isPresentation:(BOOL)isPresentation {
    self = [super init];
    if (self) {
        self.direction = direction;
        self.isPresentation = isPresentation;
    }
    return self;
}

#pragma mark -
#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.3;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    UITransitionContextViewControllerKey key = self.isPresentation? UITransitionContextToViewControllerKey:UITransitionContextFromViewControllerKey;
    UIViewController *controller = [transitionContext viewControllerForKey:key];
    if (controller == nil) { return; }
    if (self.isPresentation) {
        [transitionContext.containerView addSubview:controller.view];
    }
    CGRect presentedFrame = [transitionContext finalFrameForViewController:controller];
    CGRect dismissedFrame = presentedFrame;
    switch (self.direction) {
        case PresentationDirectionLeft:{
            dismissedFrame.origin.x = -presentedFrame.size.width;
        }
            break;
        case PresentationDirectionRight:{
            dismissedFrame.origin.x = transitionContext.containerView.frame.size.width;
        }
            break;
        case PresentationDirectionTop:{
            dismissedFrame.origin.y = -presentedFrame.size.height;
        }
            break;
        case PresentationDirectionBottom:{
            dismissedFrame.origin.y = transitionContext.containerView.frame.size.height;
        }
            break;
        default:
            break;
    }
    
    CGRect initialFrame = self.isPresentation? dismissedFrame : presentedFrame;
    CGRect finalFrame = self.isPresentation ? presentedFrame : dismissedFrame;
    CGFloat animationDuration = [self transitionDuration:transitionContext];
    controller.view.frame = initialFrame;
    
    [UIView animateWithDuration:animationDuration animations:^{
        controller.view.frame = finalFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end
