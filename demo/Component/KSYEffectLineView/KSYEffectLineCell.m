//
//  KSYEffectLineCell.m
//  demo
//
//  Created by sunyazhou on 2017/12/21.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEffectLineCell.h"

@interface KSYEffectLineCell()

@property (weak, nonatomic) IBOutlet UIImageView *effectLineImageView;

@end

@implementation KSYEffectLineCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.effectLineImageView  mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }] ;
}

- (void)setEffectLineItem:(KSYEffectLineItem *)effectLineItem{
    _effectLineItem = effectLineItem;
    self.effectLineImageView.image = effectLineItem.image;
}



@end
