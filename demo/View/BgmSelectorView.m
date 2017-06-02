//
//  BgmSelectorView.m
//  demo
//
//  Created by 张俊 on 20/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "BgmSelectorView.h"

@implementation BgmSelectorView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initSubViews];
    }
    return self;
}


- (void)initSubViews
{
    [self addSubview:self.bgmView];
    [self addSubview:self.originVolumeSlider];
    [self addSubview:self.dubVolumeSlider];
    
    [self.bgmView mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.top.equalTo(self);
        make.width.equalTo(self);
        make.height.equalTo(@100);
    }];
    
    [self.originVolumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(60);
        make.top.mas_equalTo(self.bgmView.mas_bottom).offset(8);
        make.right.mas_equalTo(self).offset(-24);
        //make.height.mas_equalTo(12);
    }];
    
    [self.dubVolumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(60);
        make.top.mas_equalTo(self.originVolumeSlider.mas_bottom).offset(12);
        make.right.mas_equalTo(self).offset(-24);
        //make.height.mas_equalTo(12);
    }];

}


-(AEMgrView *)bgmView
{
    if (!_bgmView){
        
        _bgmView = [[AEMgrView alloc] initWithIdentifier:[NSString stringWithFormat:@"%p", self]];
        //TODO move below to AEModelTemplate
        AEModelTemplate *m0 = [AEModelTemplate new];
        m0.idx = 0;
        m0.image = [UIImage imageNamed:@"closeef"];
        m0.txt  = nil;
        m0.path = nil;
        
        AEModelTemplate *m1 = [AEModelTemplate new];
        m1.idx = 1;
        m1.image = [UIImage imageNamed:@"Faded"];
        m1.txt  = @"Faded";
        m1.path = [[NSBundle mainBundle] pathForResource:@"faded_out" ofType:@"mp3"];
        
        AEModelTemplate *m2 = [AEModelTemplate new];
        m2.idx = 2;
        m2.image = [UIImage imageNamed:@"Immortals"];
        m2.txt  = @"Immortals";
        m2.path = [[NSBundle mainBundle] pathForResource:@"Immortals_out" ofType:@"mp3"];
        
        AEModelTemplate *m3 = [AEModelTemplate new];
        m3.idx = 3;
        m3.image = [UIImage imageNamed:@"cali_hotel"];
        m3.txt  = @"加州旅馆";
        m3.path = [[NSBundle mainBundle] pathForResource:@"Hotel_California_out2" ofType:@"mp3"];
        [_bgmView.dataArray addObjectsFromArray:@[m0, m1, m2, m3]];
        [_bgmView.collectionView reloadData];
    }
    return _bgmView;
}


-(UISlider *)originVolumeSlider
{
    if (!_originVolumeSlider){
        _originVolumeSlider = [self createSlider:@"原声"];
        _originVolumeSlider.tag = 0;
    }
    return _originVolumeSlider;

}

- (UISlider *)dubVolumeSlider
{
    if (!_dubVolumeSlider){
        _dubVolumeSlider = [self createSlider:@"配音"];
        _dubVolumeSlider.tag = 1;
        _dubVolumeSlider.enabled = NO;
    }
    return _dubVolumeSlider;
}

- (UISlider *)createSlider:(NSString *)title
{
    UISlider *slider = [[UISlider alloc] init];
    slider.minimumValue = 0;
    slider.maximumValue = 1;
    
    slider.thumbTintColor = [UIColor colorWithHexString:@"#ff2c53"];
    slider.maximumTrackTintColor = [UIColor colorWithHexString:@"#999999"];
    slider.minimumTrackTintColor = [UIColor colorWithHexString:@"#ff2c53"];
    [slider setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateHighlighted];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:14];
    label.text = title;
    label.textColor = [UIColor colorWithHexString:@"#999999"];
    [label sizeToFit];
    
    [slider addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(slider);
        make.trailing.equalTo(slider.mas_leading).offset(-8);
    }];
    return slider;
}

- (void)sliderValueChanged:(UISlider *)slider
{
    if (self.BgmVolumeBlock){
        
        self.BgmVolumeBlock(self.originVolumeSlider.value, self.dubVolumeSlider.value);
    }
}

@end
