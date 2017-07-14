//
//  KSYBeautyFilterCell.m
//  demo
//
//  Created by sunyazhou on 2017/7/7.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYBeautyFilterCell.h"

@interface KSYBeautyFilterCell ()

@property (weak, nonatomic) IBOutlet UILabel *beautyWhiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *buffingLabel;
@property (weak, nonatomic) IBOutlet UILabel *ruddyLabel;
@property (weak, nonatomic) IBOutlet UISlider *beautyWhiteSlider;
@property (weak, nonatomic) IBOutlet UISlider *buffingSlider;

@property (weak, nonatomic) IBOutlet UISlider *ruddySlider;


@end
@implementation KSYBeautyFilterCell


- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configSubviews];
}

- (void)configSubviews{
    //美颜
    [self.beautyWhiteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(31);
        make.top.mas_equalTo(self.mas_top).offset(25);
        make.width.equalTo(@50);
        make.height.equalTo(@16);
    }];
    
    [self.beautyWhiteSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.beautyWhiteLabel.mas_right).offset(11);
        make.right.equalTo(self.mas_right).offset(-31);
        make.centerY.equalTo(self.beautyWhiteLabel.mas_centerY);
    }];
    
    //动态特效
    [self.buffingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.beautyWhiteLabel);
        make.top.mas_equalTo(self.beautyWhiteLabel.mas_bottom).offset(16);
        
    }];
    [self.buffingSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.beautyWhiteSlider);
        make.centerY.equalTo(self.buffingLabel.mas_centerY);
    }];
    
    //滤镜
    [self.ruddyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.buffingLabel);
        make.top.mas_equalTo(self.buffingLabel.mas_bottom).offset(16);
    }];
    [self.ruddySlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.buffingSlider);
        make.centerY.equalTo(self.ruddyLabel.mas_centerY);
    }];
}

- (IBAction)beautyFilterSliderValueChange:(UISlider *)sender {
    [self notifyDelegate:KSYMEBeautyKindTypeFaceWhiten andValue:sender.value];
}

- (IBAction)buffingSliderValueChange:(UISlider *)sender {
    [self notifyDelegate:KSYMEBeautyKindTypeGrind andValue:sender.value];
}

- (IBAction)ruddySliderValueChange:(UISlider *)sender {
    [self notifyDelegate:KSYMEBeautyKindTypeRuddy andValue:sender.value];
}

- (void)notifyDelegate:(KSYMEBeautyKindType)kind andValue:(CGFloat)value{
    if ([self.delegate respondsToSelector:@selector(beautyFilterCell:filterType:filterIndex:)]) {
        [self.delegate beautyFilterCell:self filterType:kind filterIndex:value];
    }
}
@end
