//
//  KSYDynamicEffectCell.m
//  demo
//
//  Created by sunyazhou on 2017/7/10.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYDynamicEffectCell.h"

@interface KSYDynamicEffectCell()

@end

@implementation KSYDynamicEffectCell

- (void)awakeFromNib {
    [super awakeFromNib];

    _stickerView = [[StickerView alloc] initWithType:2];
    _stickerView.delegate = self;

    [self.contentView addSubview:_stickerView];

    [_stickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.contentView );
    }];
    self.stickerView.backgroundColor = [UIColor clearColor];
}

@end
