//
//  TrimBgView.m
//  demo
//
//  Created by sunyazhou on 2017/6/16.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "TrimBgView.h"

@implementation TrimBgView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)videoAction:(UIButton *)sender {
    [self notifyDelegate:TrimMeidaTypeVideo];
}

- (IBAction)audioAction:(UIButton*)sender {
    [self notifyDelegate:TrimMeidaTypeAudio];
}

- (void)notifyDelegate:(TrimMeidaType)type{
    if ([self.delegate respondsToSelector:@selector(trimBgView:clickIndex:)]) {
        [self.delegate trimBgView:self clickIndex:type];
    }
}


@end
