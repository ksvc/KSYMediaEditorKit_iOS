//
//  BeautyConfigView.m
//  
//
//  Created by iVermisseDich on 16/12/7.
//  Copyright © 2016年 com.ksyun. All rights reserved.
//

#import "BeautyConfigView.h"

#define kBeautySliderTag 100

@interface BeautyConfigView ()

// 美颜参数调节
@property (nonatomic, strong) UISlider *whiteningSlider;        // 美白 tag kBeautySliderTag
@property (nonatomic, strong) UISlider *grindSlider;            // 磨皮 tag:kBeautySliderTag+1
@property (nonatomic, strong) UISlider *ruddySlider;            // 红润 tag:kBeautySliderTag+2

@end

@implementation BeautyConfigView

- (instancetype)init{
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = RGBCOLOR(250, 250, 250);

    // 2.1 美白
    _whiteningSlider = [self createSliderWithTitle:@"美白" value:0.3f];
    _whiteningSlider.tag = kBeautySliderTag;
    
    // 2.2 磨皮
    _grindSlider = [self createSliderWithTitle:@"磨皮" value:0.5f];
    _grindSlider.tag = kBeautySliderTag + 1;
    
    // 2.3 红润
    _ruddySlider = [self createSliderWithTitle:@"红润" min:-1.0f max:1.0f val:-0.3f];
    _ruddySlider.tag = kBeautySliderTag + 2;
    
    // add subviews
    [self addSubview:_grindSlider];
    [self addSubview:_whiteningSlider];
    [self addSubview:_ruddySlider];
    
    
    [_grindSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.trailing.equalTo(self).offset(-41);
        make.width.mas_equalTo(240);
        make.centerY.equalTo(self);
    }];
    
    [_whiteningSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.leading.equalTo(_grindSlider);
        make.trailing.equalTo(_grindSlider);
        make.top.equalTo(self).offset(27.5);
    }];
    
    [_ruddySlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.leading.equalTo(_grindSlider);
        make.trailing.equalTo(_grindSlider);
        make.bottom.equalTo(self).offset(-27.5);
    }];
}

#pragma mark - Actions

- (void)sliderValueChanged:(UISlider *)slider{
    if ([self.delegate respondsToSelector:@selector(beautyParameter:valueDidChanged:)]) {
        [self.delegate beautyParameter:(BeautyParameter)(slider.tag - kBeautySliderTag) valueDidChanged:slider.value];
    }
}

#pragma mark - Universal funcs

- (UISlider *)createSliderWithTitle:(NSString *)title
{
    return [self createSliderWithTitle:title min:0.0 max:1.0 val:0];
}

- (UISlider *)createSliderWithTitle:(NSString *)title value:(float)value
{
    return [self createSliderWithTitle:title min:0.0 max:1.0 val:value];
}

- (UISlider *)createSliderWithTitle:(NSString *)title  min:(float)minValue  max:(float)maxValue val:(float)value{
    UISlider *slider = [[UISlider alloc] init];
    
    slider.maximumValue = maxValue;
    slider.minimumValue = minValue;
    slider.value = value;
    slider.thumbTintColor = [UIColor colorWithHexString:@"#ffba00"];
    slider.maximumTrackTintColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
    slider.minimumTrackTintColor = [UIColor colorWithHexString:@"#ffba00"];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:11];
    label.text = title;
    [label sizeToFit];
    
    [slider addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(slider);
        make.trailing.equalTo(slider.mas_leading).offset(-10);
    }];
    
    return slider;
}

@end
