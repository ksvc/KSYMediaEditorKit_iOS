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
        make.center.equalTo(self);
        make.height.mas_equalTo(40);
    }];
    
    [self.segment setSelectedSegmentIndex:self.levelModel.level];
}

- (IBAction)segmentControlAction:(UISegmentedControl *)sender {
    if ([self.delegate respondsToSelector:@selector(editLevel:)]) {
        [self.delegate editLevel:sender.selectedSegmentIndex];
    }
}


@end
