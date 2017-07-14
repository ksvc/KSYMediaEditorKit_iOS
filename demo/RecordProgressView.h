//
//  RecordProgressView.h
//  demo
//
//  Created by iVermisseDich on 2017/7/6.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordProgressView : UIView

- (instancetype)initWithMinIndicator:(CGFloat)indicator;

- (void)addRangeView;

- (void)removeLastRangeView;

- (void)updateLastRangeView:(CGFloat)widthRatio;

@property(nonatomic, assign)BOOL lastRangeViewSelected;

@end
