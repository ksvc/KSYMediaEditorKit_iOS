//
//  KSYEditVideoTrimCell.m
//  demo
//
//  Created by sunyazhou on 2017/7/14.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEditVideoTrimCell.h"
#import "SAVideoRangeSlider.h"

@interface KSYEditVideoTrimCell () <SAVideoRangeSliderDelegate>

@property (strong, nonatomic)  SAVideoRangeSlider *sclipSlider;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;

@end
@implementation KSYEditVideoTrimCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configSubviws];
}


- (void)configSubviws{
    self.sclipSlider  = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(20, 20, kScreenWidth-40, 70)];
    self.sclipSlider.delegate = self;
    [self addSubview:self.sclipSlider];
    [self.sclipSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(20, 20, 20, 20));
    }];
    
    [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.mas_equalTo(self.mas_top).offset(10);
        make.height.equalTo(@14);
    }];
    self.topLabel.textColor = [UIColor jk_colorWithHex:0x9b9b9b andAlpha:0];
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.videoURL) {
        self.sclipSlider.videoUrl = self.videoURL;
        [self.sclipSlider getMovieFrame];
    }
}

- (void)prepareForReuse{
    if (self.videoURL) {
        self.sclipSlider.videoUrl = self.videoURL;
    }
}

#pragma mark -
#pragma mark -  SAVideoRangeSlider Delegate
- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition touchLeft:(bool)touchLeft{
    
}

- (void)videoRange:(SAVideoRangeSlider *)videoRange didGestureStateEndedLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition{
    
}

@end
