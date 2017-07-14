//
//  FilterChoiceView.m
//  demo
//
//  Created by 张俊 on 06/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "FilterChoiceView.h"
#import "UIButton+init.h"
#import "UIColor+Expanded.h"

#define kBeautySliderTag 100
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

@interface FilterChoiceView ()

@property (nonatomic, weak) UIButton *currentBtn;

@end

@implementation FilterChoiceView

- (instancetype)init{
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    // 默认美颜算法
    //[self beautyBtnSelected:_currentBtn];
}

- (void)setupUI{
    self.backgroundColor = RGBCOLOR(250, 250, 250);
    //[self addGestureRecognizer:[[UITapGestureRecognizer alloc] init]];
    /* 1. 美颜算法选择视图 */
    UIView *algoView = [[UIView alloc] init];
    algoView.backgroundColor = [UIColor whiteColor];
    
    CGRect btnFrame = CGRectMake(0, 0, 50, 50);
    // 1.1 柔肤
    UIButton *smoothBtn = [UIButton buttonWithFrame:btnFrame target:self normal:@"beauty_smooth" highlited:nil selected:@"beauty_smooth" selector:@selector(beautyBtnSelected:)];
    smoothBtn.tag = KSYFilterBeautifyPlus;
    [self configButton:smoothBtn withTitle:@"柔肤"];
    smoothBtn.selected = NO;
    
    
    // 1.3 白皙
     UIButton *fairBtn = [UIButton buttonWithFrame:btnFrame target:self normal:@"beauty_fair" highlited:nil selected:@"beauty_fair" selector:@selector(beautyBtnSelected:)];
     fairBtn.tag = KSYFilterBeautifyPRO;
     [self configButton:fairBtn withTitle:@"白皙"];
     fairBtn.selected = NO;
     
    
    // add subviews
    [self addSubview:algoView];
    [algoView addSubview:smoothBtn];
    [algoView addSubview:fairBtn];
    
    // make constraint
    [algoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    // 此处增大了按钮的大小，扩大响应范围
    [smoothBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(algoView).offset(50);
        make.centerY.equalTo(algoView);
        make.width.mas_equalTo(60);
        make.height.equalTo(algoView);
    }];
    
    [fairBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(algoView);
        make.width.height.equalTo(smoothBtn);
        make.trailing.equalTo(algoView).offset(-50);
    }];
    
    /* 2. 美颜算法参数设置视图 */
    UIView *paramsSettingView = [[UIView alloc] init];
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
    [self addSubview:paramsSettingView];
    [paramsSettingView addSubview:_grindSlider];
    [paramsSettingView addSubview:_whiteningSlider];
    [paramsSettingView addSubview:_ruddySlider];
    
    // make constraint
    [paramsSettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self);
        make.bottom.equalTo(algoView.mas_top);
    }];
    
    [_grindSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(paramsSettingView);
        make.trailing.equalTo(paramsSettingView).offset(-41);
        make.centerY.equalTo(paramsSettingView);
    }];
    
    [_whiteningSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(paramsSettingView);
        make.leading.equalTo(_grindSlider);
        make.trailing.equalTo(_grindSlider);
        make.top.equalTo(paramsSettingView).offset(27.5);
    }];
    
    [_ruddySlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(paramsSettingView);
        make.leading.equalTo(_grindSlider);
        make.trailing.equalTo(_grindSlider);
        make.bottom.equalTo(paramsSettingView).offset(-27.5);
    }];
}

#pragma mark - Actions
- (void)beautyBtnSelected:(UIButton *)button{
    _currentBtn.selected = NO;
    button.selected = YES;
    
    if ([self.delegate respondsToSelector:@selector(beautyFilterDidSelected:)]) {
        [self.delegate beautyFilterDidSelected:button.tag];
    }
    _currentBtn = button;
    
}

- (void)sliderValueChanged:(UISlider *)slider{
    if ([self.delegate respondsToSelector:@selector(beautyParameter:valueDidChanged:)]) {
        [self.delegate beautyParameter:(BeautyParameter)(slider.tag - kBeautySliderTag) valueDidChanged:slider.value];
    }
}

#pragma mark - Universal funcs
// 调整button内部布局
- (void)configButton:(UIButton *)btn withTitle:(NSString *)title{
    [btn setAdjustsImageWhenHighlighted:NO];
    btn.imageEdgeInsets = UIEdgeInsetsMake(-5, 10, 5, -10);
    btn.titleEdgeInsets = UIEdgeInsetsMake(25, -12, 0, 12);
    btn.titleLabel.font = [UIFont systemFontOfSize:11];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHexString:@"#000000"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHexString:@"#ff8c10"] forState:UIControlStateSelected];
}

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

- (UIButton *)buttonWithFrame:(CGRect)rect target:(id)target normal:(NSString *)image_nm highlited:(NSString *)image_hl selected:(NSString *)image_sel selector:(SEL)sel{
    // frame
    UIButton *btn = [[UIButton alloc] initWithFrame:rect];
    // target
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    // image
    [btn setImage:[UIImage imageNamed:image_nm] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:image_hl] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:image_sel] forState:UIControlStateSelected];
    [btn sizeToFit];
    return btn;
}
@end
