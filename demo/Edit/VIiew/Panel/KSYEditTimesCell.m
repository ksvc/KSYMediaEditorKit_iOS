//
//  KSYEditTimesCell.m
//  demo
//
//  Created by sunyazhou on 2017/7/18.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEditTimesCell.h"
#import <SMPageControl/SMPageControl.h>

@interface KSYEditTimesCell ()

@property (nonatomic, assign) NSUInteger lastPage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;

@property (weak, nonatomic) IBOutlet UISegmentedControl *TimeEffectSeg;

@end

@implementation KSYEditTimesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configSubviws];
}


- (void)configSubviws{
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self.segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(40);
        make.right.equalTo(self).offset(-40);
        make.center.equalTo(self).offset(-20);
        make.height.mas_equalTo(30);
    }];
    
    [self.TimeEffectSeg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(40);
        make.right.equalTo(self).offset(-40);
        make.center.equalTo(self).offset(20);
        make.height.mas_equalTo(30);
    }];
    
    [self.segment setSelectedSegmentIndex:self.levelModel.level];
    [self.TimeEffectSeg setSelectedSegmentIndex:self.levelModel.timeEffectType];
}

- (IBAction)segmentControlAction:(UISegmentedControl *)sender {
    if ([self.delegate respondsToSelector:@selector(editLevel:)]) {
        [self.delegate editLevel:sender.selectedSegmentIndex];
    }
}

- (IBAction)TimeEffectSegmentControlAction:(UISegmentedControl *)sender {
    if ([self.delegate respondsToSelector:@selector(editTimeEffect:)]) {
        NSInteger idx = sender.selectedSegmentIndex;
        [self.delegate editTimeEffect:idx];
    }
}

@end
