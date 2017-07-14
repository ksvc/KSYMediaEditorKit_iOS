//
//  TrimMaskView.h
//  demo
//
//  Created by 张俊 on 04/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrimMaskView : UIView


-(void)updateTrimMaskRight:(CGFloat)offset;

-(void)updateTrimMaskLeft:(CGFloat)offset;

@property (nonatomic, copy) void(^moveRangeBlock)(CGFloat offset);

@end
