//
//  KSYEditStickerCollectionViewCell.m
//  demo
//
//  Created by sunyazhou on 2017/7/14.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEditStickerCollectionViewCell.h"

@interface KSYEditStickerCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *stickerImageView;

@end

@implementation KSYEditStickerCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configSubview];
    
}

- (void)configSubview{
    [self.stickerImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.model.bgmImageName.length > 0) {
        self.stickerImageView.image = [UIImage imageNamed:self.model.bgmImageName];
    }
    
    [self showBorder:self.model.isSelected];
    
}

- (void)prepareForReuse{
    [self showBorder:self.model.isSelected];
    
    
}

- (void)showBorder:(BOOL)selected{
    
    if (selected) {
        self.stickerImageView.layer.borderWidth = 2;
        self.stickerImageView.layer.borderColor = [UIColor redColor].CGColor;
    }else {
        self.stickerImageView.layer.borderWidth = 0;
        self.stickerImageView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}
@end
