//
//  KSYEditWatermarkCell.m
//  demo
//
//  Created by sunyazhou on 2017/7/14.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEditWatermarkCell.h"

@interface KSYEditWatermarkCell ()

@property (weak, nonatomic) IBOutlet UIButton *watermarkBtn;


@end

@implementation KSYEditWatermarkCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.show = NO;
    
    [self.watermarkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateTitleByStatus:self.show];
}

- (void)prepareForReuse{
    [self updateTitleByStatus:self.show];
}

- (void)updateTitleByStatus:(BOOL)show{
    NSString *watermarkString = nil;
    if (show) {
        watermarkString = @"取消水印";
    } else {
        watermarkString = @"开启水印";
    }
    [self.watermarkBtn setTitle:watermarkString forState:UIControlStateNormal];
    [self.watermarkBtn setTitle:watermarkString forState:UIControlStateHighlighted];
}

- (IBAction)watermarkAction:(UIButton *)sender {
    self.show = !self.show;
    [self updateTitleByStatus:self.show];
    if ([self.delegate respondsToSelector:@selector(editWatermarkCell:showWatermark:)]) {
        [self.delegate editWatermarkCell:self showWatermark:self.show];
    }
}
@end
