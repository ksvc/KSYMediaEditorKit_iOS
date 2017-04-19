//
//  NavigateView.m
//  demo
//
//  Created by 张俊 on 08/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "NavigateView.h"

@implementation NavigateView


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self addSubview:self.backBtn];
        [self addSubview:self.nextBtn];

    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.centerY.equalTo(self).offset(10);
    }];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.right.equalTo(self).offset(-16);
        make.centerY.equalTo(self).offset(10);
    }];
    
}



- (UIButton *)backBtn
{
    if (!_backBtn){
        _backBtn = [UIButton  buttonWithType:UIButtonTypeCustom];
        _backBtn.tag = 0;
        [_backBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    return _backBtn;

}

- (UIButton *)nextBtn
{
    if (!_nextBtn){
        _nextBtn = [UIButton  buttonWithType:UIButtonTypeCustom];
        _nextBtn.tag = 1;
        [_nextBtn setTitle:@"发布" forState:UIControlStateNormal];
        [_nextBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

-(void)onClick:(UIButton *)sender
{
    if (self.onEvent){
        self.onEvent(sender.tag, 0);
    }
}

@end
