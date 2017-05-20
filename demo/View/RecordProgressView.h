//
//  RecordProgressView.h
//  demo
//
//  Created by 张俊 on 15/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordProgressView : UIView

- (instancetype)initWithFrame:(CGRect)frame minIndicator:(CGFloat)indicator;

- (void)addRangeView;

- (void)removeLastRangeView;

- (void)updateLastRangeView:(CGFloat)widthRatio;

@property(nonatomic, assign)BOOL lastRangeViewSelected;

@end
