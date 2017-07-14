//
//  TrimMaskView.m
//  demo
//
//  Created by 张俊 on 04/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "TrimMaskView.h"

@interface TrimMaskView()
{

}

@property(nonatomic, assign)CGRect transparentArea;

@end

@implementation TrimMaskView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onMove:)];
        panGestureRecognizer.delaysTouchesBegan = YES;
        [self addGestureRecognizer:panGestureRecognizer];
        
    }
    return self;
}

-(void)updateTrimMaskLeft:(CGFloat)offset
{
    self.transparentArea = CGRectMake(offset + self.transparentArea.origin.x,
                                      self.transparentArea.origin.y,
                                      self.transparentArea.size.width - offset,
                                      self.transparentArea.size.height);
    [self setNeedsDisplay];
}

-(void)updateTrimMaskRight:(CGFloat)offset
{
    self.transparentArea = CGRectMake(self.transparentArea.origin.x,
                                      self.transparentArea.origin.y,
                                      self.transparentArea.size.width + offset,
                                      self.transparentArea.size.height);
    [self setNeedsDisplay];
}


- (void)onMove:(UIPanGestureRecognizer *)sender
{
    UIPanGestureRecognizer *gestureRecognizer = sender;
    
    CGPoint translation = [gestureRecognizer translationInView:self];

    CGFloat deltaX = translation.x;
    
    if(self.moveRangeBlock){
        self.moveRangeBlock(deltaX);

    }
    //gestureRecognizer.view.center = CGPointMake(centerX, centerY);
    
    [gestureRecognizer setTranslation:CGPointZero inView:self];
    

}

- (void)drawRect:(CGRect)rect
{
    
    [[UIColor colorWithWhite:0 alpha:0.5] setFill];
    UIRectFill(rect);
    CGRect subRect = self.transparentArea;
    if (CGRectIsEmpty(self.transparentArea)){
        subRect = rect;
        self.transparentArea = subRect;
    }
    
    CGRect interSection = CGRectIntersection(subRect, rect);
    [[UIColor clearColor] setFill];
    UIRectFill(interSection);

}

@end
