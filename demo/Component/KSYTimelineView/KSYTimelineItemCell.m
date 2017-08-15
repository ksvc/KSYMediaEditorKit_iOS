//
//  KSYTimelineItemCell.m
//  demo
//
//  Created by sunyazhou on 2017/8/2.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYTimelineItemCell.h"
@implementation KSYTimelinePercent

@end

@interface KSYTimelineItemCell()
@property (nonatomic, strong) UIView *greyView;  //时间段视图
@property (nonatomic, strong) NSMutableArray *greyViews;
@property (nonatomic, strong) NSMutableArray *percents;


@end
@implementation KSYTimelineItemCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIColor *backgroundColor = [UIColor clearColor];
        self.backgroundColor = backgroundColor;
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
        self.greyView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.greyView];
        self.greyView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.4];
        self.greyView.hidden = YES;
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.bounds = self.bounds;
}

- (void)refreshGreyviews
{
    for (KSYTimelinePercent *percent in self.percents) {
        CGFloat x = percent.leftPercent * self.bounds.size.width;
        CGFloat width = (percent.rightPercent - percent.leftPercent) * self.bounds.size.width;
        CGRect frame = CGRectMake(x, 0, width, CGRectGetHeight(self.bounds));
        UIView *greyview = [[UIView alloc] initWithFrame:frame];
        greyview.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.4];
        [self addSubview:greyview];
        [self.greyViews addObject:greyview];
    }
}

- (void)setMappedBeginTime:(CGFloat)mappedBeginTime endTime:(CGFloat)mappedEndTime image:(UIImage *)image timelinePercents:(NSArray *)percents
{
    self.mappedBeginTime = mappedBeginTime;
    self.mappedEndTime = mappedEndTime;
    [self.imageView setImage:image];
    
    [self.percents removeAllObjects];
    [self.percents addObjectsFromArray:percents];
    [self.greyViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.greyViews removeAllObjects];
    
    [self refreshGreyviews];
}

- (NSMutableArray *)greyViews
{
    if (!_greyViews) {
        _greyViews = [[NSMutableArray alloc] init];
    }
    return _greyViews;
}

- (NSMutableArray *)percents
{
    if (!_percents) {
        _percents = [[NSMutableArray alloc] init];
    }
    return _percents;
}

@end
