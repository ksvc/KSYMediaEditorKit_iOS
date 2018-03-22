//
//  KSYTransTagCell.m
//  demo
//
//  Created by sunyazhou on 2017/10/26.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYTransTagCell.h"

@interface KSYTransTagCell()
@property (weak, nonatomic) IBOutlet UIImageView *tagImage;

@end

@implementation KSYTransTagCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configSubview];
}

- (void)configSubview{
    [self.tagImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self showBorder:self.model.isSelected];
}

- (void)prepareForReuse{
    [super prepareForReuse];
    [self configSubview];
    [self setModel:_model];
    [self showBorder:self.model.isSelected];
}

- (void)setModel:(KSYTransModel *)model{
    _model = model;
    [self showBorder:model.isSelected];
    if (model.type == KSYTransCellTypeTrans) {
        UIImage *normalImage = [UIImage imageNamed:@"ksy_ME_preEdit_trans_tag_normal"];
        UIImage *selectedImage = [UIImage imageNamed:@"ksy_ME_preEdit_trans_tag_selected"];
        self.tagImage.image = model.isSelected?selectedImage:normalImage;
    } else {
        self.tagImage.image = nil;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.tagImage.alpha = highlighted ? 0.75f : 1.0f;
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
