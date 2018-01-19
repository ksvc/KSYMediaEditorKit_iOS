//
//  KSYEditFilterEffectColllectionViewCell.m
//  demo
//
//  Created by sunyazhou on 2017/12/26.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEditFilterEffectColllectionViewCell.h"

@interface KSYEditFilterEffectColllectionViewCell()


@property (weak, nonatomic) IBOutlet UILabel *effectLabel;

@end

@implementation KSYEditFilterEffectColllectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes{
    [self.effectImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top);
        make.width.height.mas_lessThanOrEqualTo(50);
    }];
    
    [self.effectLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.effectImageView.mas_bottom);
        make.height.equalTo(@20);
    }];
}

- (void)setModel:(KSYFilterEffectModel *)model{
    _model = model;
    self.effectImageView.image = [UIImage imageNamed:model.imgName];
    self.effectLabel.text = model.effectName;
}


- (void)zoomCellWithRatio:(CGFloat)startRatio andState:(UIGestureRecognizerState)state{
    
    if (state == UIGestureRecognizerStateBegan) {
        CGAffineTransform transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.3 animations:^{
            self.effectImageView.transform = CGAffineTransformScale(transform, startRatio, startRatio);
        }];
    } else if (state == UIGestureRecognizerStateChanged) {
        
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.effectImageView.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
