//
//  KSYRecordAECommonCell.m
//  demo
//
//  Created by sunyazhou on 2017/7/12.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYRecordAECommonCell.h"


@interface KSYRecordAECommonCell ()
@property (weak, nonatomic) IBOutlet UIImageView *aeImageView;
@property (weak, nonatomic) IBOutlet UILabel *aeLabel;

@end

@implementation KSYRecordAECommonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configSubview];
    
}

- (void)configSubview{
    [self.aeImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(63);
    }];
    
    [self.aeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.top.mas_equalTo(self.aeImageView.mas_bottom).offset(2);
    }];
    self.aeLabel.textColor = [UIColor colorWithHexString:@"#9b9b9b"];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.model.bgmImageName.length > 0) {
        self.aeImageView.image = [UIImage imageNamed:self.model.bgmImageName];
    }
    if (self.model.bgmName.length > 0) {
        self.aeLabel.text = self.model.bgmName;
    } else{
        self.aeLabel.text = @"";
    }
    
    [self showBorder:self.model.isSelected];
    
}

- (void)prepareForReuse{
    [self showBorder:self.model.isSelected];
    
    
}

- (void)showBorder:(BOOL)selected{
    
    if (selected) {
        self.aeImageView.layer.borderWidth = 2;
        self.aeImageView.layer.borderColor = [UIColor redColor].CGColor;
    }else {
        self.aeImageView.layer.borderWidth = 0;
        self.aeImageView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
