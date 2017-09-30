//
//  KSYEditMVCell.m
//  demo
//
//  Created by sunyazhou on 2017/9/12.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEditMVCell.h"



@interface KSYEditMVCell ()
@property (weak, nonatomic) IBOutlet UIImageView *mvImageView;
@property (weak, nonatomic) IBOutlet UILabel *mvLabel;

@end

@implementation KSYEditMVCell
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configSubview];
    
}

- (void)configSubview{
    [self.mvImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(63);
    }];
    
    [self.mvLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.top.mas_equalTo(self.mvImageView.mas_bottom).offset(2);
    }];
    self.mvLabel.textColor = [UIColor colorWithHexString:@"#9b9b9b"];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.model.bgmImage.length > 0) {
        self.mvImageView.image = [UIImage imageNamed:self.model.bgmImage];
    }
    if (self.model.mvName.length > 0) {
        self.mvLabel.text = self.model.mvName;
    } else{
        self.mvLabel.text = @"";
    }
    
    [self showBorder:self.model.isSelected];
    
}

- (void)prepareForReuse{
    [self showBorder:self.model.isSelected];
    
    
}

- (void)showBorder:(BOOL)selected{
    
    if (selected) {
        self.mvImageView.layer.borderWidth = 2;
        self.mvImageView.layer.borderColor = [UIColor redColor].CGColor;
    }else {
        self.mvImageView.layer.borderWidth = 0;
        self.mvImageView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
