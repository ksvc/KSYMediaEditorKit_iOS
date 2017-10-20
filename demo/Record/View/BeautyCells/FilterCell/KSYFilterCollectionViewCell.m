//
//  KSYFilterCollectionViewCell.m
//  demo
//
//  Created by sunyazhou on 2017/7/10.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYFilterCollectionViewCell.h"

@interface KSYFilterCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *filterImageView;
@property (weak, nonatomic) IBOutlet UILabel *filterLabel;


@end

@implementation KSYFilterCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configSubview];
    
}

- (void)configSubview{
    [self.filterImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.top).offset(10);
        make.centerX.equalTo(self.mas_centerX);
        make.width.height.mas_equalTo(63);
    }];
    
    [self.filterLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.top.mas_equalTo(self.filterImageView.mas_bottom).offset(2);
    }];
    self.filterLabel.textColor = [UIColor colorWithHexString:@"#9b9b9b"];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.model.imageName.length > 0) {
        self.filterImageView.image = [UIImage imageNamed:self.model.imageName];
    }
    if (self.model.filterName.length > 0) {
        self.filterLabel.text = self.model.filterName;
    }
    
    [self showBorder:self.model.isSelected];
    
}

- (void)prepareForReuse{
    [self showBorder:self.model.isSelected];
}

- (void)showBorder:(BOOL)selected{
    if (selected) {
        self.filterImageView.layer.borderWidth = 2;
        self.filterImageView.layer.borderColor = [UIColor redColor].CGColor;
    }else {
        self.filterImageView.layer.borderWidth = 0;
        self.filterImageView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
