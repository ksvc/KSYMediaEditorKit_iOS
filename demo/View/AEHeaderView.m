//
//  AEHeaderView.m
//  demo
//
//  Created by 张俊 on 20/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "AEHeaderView.h"

@interface AEHeaderView ()

@property(nonatomic, strong)UIImageView *imagView;

@end

@implementation AEHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //
        [self addSubview:self.imagView];
        [self.imagView mas_makeConstraints:^(MASConstraintMaker *make) {
            //
            make.center.equalTo(self);
        }];
    }
    return self;
}


- (UIImageView *)imagView
{
    if (!_imagView){
        _imagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"closeef"]];
    }
    return _imagView;
}

@end
