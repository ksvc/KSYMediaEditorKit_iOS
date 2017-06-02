//
//  BeautyConfigView.m
//  
//
//  Created by iVermisseDich on 16/12/7.
//  Copyright © 2016年 com.ksyun. All rights reserved.
//

#import "EffectView.h"

#define buttonCount 3

@interface EffectView ()

@property (nonatomic, strong) UIButton *beautyBtn; //美颜按钮
@property (nonatomic, strong) UIButton *ARFilterBtn; //贴纸按钮
@property (nonatomic, strong) UIButton * filterBtn; //滤镜按钮

@end



@implementation EffectView

- (instancetype)init{
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = RGBCOLOR(250, 250, 250);
    /* 1. 底部选择选择视图 */
    UIView *algoView = [[UIView alloc] init];
    algoView.backgroundColor = [UIColor whiteColor];
    CGRect btnFrame = CGRectMake(0, 0, 50, 50);
    
    // 美颜按钮
    _beautyBtn = [UIButton buttonWithFrame:btnFrame target:self normal:@"beauty_tender" highlited:nil selected:@"beauty_tender" selector:@selector(btnSelected:)];
    [self configButton:_beautyBtn withTitle:@"美颜"];

    
    // 贴纸按钮
    _ARFilterBtn = [UIButton buttonWithFrame:btnFrame target:self normal:@"arFilter" highlited:nil selected:@"arFilter" selector:@selector(btnSelected:)];
    [self configButton:_ARFilterBtn withTitle:@"贴纸"];
    
    // 滤镜按钮
    _filterBtn = [UIButton buttonWithFrame:btnFrame target:self normal:@"filter" highlited:nil selected:@"filter" selector:@selector(btnSelected:)];
    [self configButton:_filterBtn withTitle:@"滤镜"];
    
    //顶部调节view
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor whiteColor];
    
    //美颜view
    _beautyConfigView = [[BeautyConfigView alloc] init];
    
    //贴纸view
    _stickerView = [[StickerView alloc] init];
    
    //滤镜view
    _filterView = [[FilterView alloc] init];
    [self btnSelected:_beautyBtn];
    
    // add subviews
    [self addSubview:topView];
    [topView addSubview:_beautyConfigView];
    [topView addSubview:_stickerView];
    [topView addSubview:_filterView];
    [self addSubview:algoView];
    [algoView addSubview:_beautyBtn];
    [algoView addSubview:_ARFilterBtn];
    [algoView addSubview:_filterBtn];
    
    // make constraint
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.bottom.equalTo(algoView.mas_top);
    }];
    
    [_beautyConfigView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(topView);
    }];
    
    [_filterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(topView);
    }];
    
    [_stickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(topView);
    }];
    
    [algoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.mas_equalTo(47);
    }];
    
    [_beautyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(algoView);
        make.width.equalTo(algoView.mas_width).multipliedBy(1.0/buttonCount);
    }];
    [_beautyBtn.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_beautyBtn).offset(40);
    }];

    
    [_ARFilterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(algoView);
        make.leading.equalTo(_beautyBtn.mas_trailing);
        make.width.equalTo(algoView.mas_width).multipliedBy(1.0/buttonCount);
    }];
    
    [_filterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(algoView);
        make.leading.equalTo(_ARFilterBtn.mas_trailing);
        make.width.equalTo(algoView.mas_width).multipliedBy(1.0/buttonCount);
    }];
    [_filterBtn.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-40);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

}

#pragma mark - Actions
-(void)btnSelected:(UIButton* )sender{
    
    if(sender == _beautyBtn){
        _beautyBtn.selected = YES;
        _ARFilterBtn.selected = NO;
        _filterBtn.selected = NO;
        _beautyConfigView.hidden = NO;
        [self sendSubviewToBack:_beautyConfigView];
        _filterView.hidden = YES;
        _stickerView.hidden = YES;
    }else if(sender == _ARFilterBtn){
        _beautyBtn.selected = NO;
        _ARFilterBtn.selected = YES;
        _filterBtn.selected = NO;
        _beautyConfigView.hidden = YES;
        _filterView.hidden = YES;
        [self sendSubviewToBack:_stickerView];
        _stickerView.hidden = NO;
    }else if(sender == _filterBtn){
        _beautyBtn.selected = NO;
        _ARFilterBtn.selected = NO;
        _filterBtn.selected = YES;
        _beautyConfigView.hidden = YES;
        [self sendSubviewToBack:_filterView];
        _filterView.hidden = NO;
        _stickerView.hidden = YES;
    }
}



#pragma mark - Universal funcs
// 调整button内部布局
- (void)configButton:(UIButton *)btn withTitle:(NSString *)title{
    [btn setAdjustsImageWhenHighlighted:NO];
    
    //设置为上图片下文字
    //btn.frame = rect;
    CGFloat totalHeight = (btn.imageView.frame.size.height + btn.titleLabel.frame.size.height + 10);
    [btn setImageEdgeInsets:UIEdgeInsetsMake(-(totalHeight - btn.imageView.frame.size.height), 40, 0.0, -btn.titleLabel.frame.size.width)];
    if (btn == _beautyBtn ||btn == _filterBtn) {
        [btn setImageEdgeInsets:UIEdgeInsetsMake(-(totalHeight - btn.imageView.frame.size.height), 40, 0.0, -btn.titleLabel.frame.size.width)];
    }else if(btn == _ARFilterBtn){
         [btn setImageEdgeInsets:UIEdgeInsetsMake(-(totalHeight - btn.imageView.frame.size.height), 31, 0.0, -btn.titleLabel.frame.size.width)];
    }
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -btn.imageView.frame.size.width, -(totalHeight - btn.titleLabel.frame.size.height),0.0)];
//    btn.imageEdgeInsets = UIEdgeInsetsMake(-30, 20, 10, -15);
//    btn.titleEdgeInsets = UIEdgeInsetsMake(25, -12, 0, 12);
    btn.titleLabel.font = [UIFont systemFontOfSize:11];;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHexString:@"#000000"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHexString:@"#ff8c10"] forState:UIControlStateSelected];
}
@end
