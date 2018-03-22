//
//  SlideInPresentationAnimator.h
//  Nemo
//
//  Created by sunyazhou on 2017/6/9.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SlideInPresentationManager.h"
@interface SlideInPresentationAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property(nonatomic, assign) PresentationDirection direction;
@property(nonatomic, assign) BOOL isPresentation;

- (instancetype)initWithDirection:(PresentationDirection)direction
                   isPresentation:(BOOL)isPresentation;
@end
