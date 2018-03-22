//
//  KSYBgmCell.m
//  demo
//
//  Created by sunyazhou on 2017/7/11.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYBgmCell.h"


@interface KSYBgmCell()

@property (weak, nonatomic) IBOutlet UIImageView *bgmImageView;
@property (weak, nonatomic) IBOutlet UILabel *bgmNameLabel;


@end
@implementation KSYBgmCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configSubveiws];
}

- (void)configSubveiws{
    [self.bgmImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.bgmNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.equalTo(@18);
    }];
    
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.bgmImageView.image = [UIImage imageNamed:self.model.bgmImageName];
    
    self.bgmNameLabel.text = self.model.bgmName;
    if (self.model.bgmName.length > 0) {
        self.bgmNameLabel.hidden = NO;
    } else {
        self.bgmNameLabel.hidden = YES;
    }
    
    [self showBorder:self.model.isSelected];
}

- (void)prepareForReuse{
    [self showBorder:self.model.isSelected];
}

- (void)showBorder:(BOOL)selected{
    if (selected) {
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor redColor].CGColor;
    }else {
        self.layer.borderWidth = 0;
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
