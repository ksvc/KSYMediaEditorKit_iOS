//
//  AEMgrCellView.m
//  demo
//
//  Created by 张俊 on 20/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "AEMgrCellView.h"

@interface AEMgrCellView (){
    BOOL _isOrigin;
}

//图
@property(nonatomic, strong)UIImageView *thumb;

//文
@property(nonatomic, strong)UILabel *tips;

@end

@implementation AEMgrCellView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}


- (void)initSubViews
{
    [self addSubview:self.thumb];
    [self addSubview:self.tips];
    
    [self.thumb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self.mas_top).offset(38);
    }];
    
    [self.tips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self.mas_top).offset(88);
        
    }];
}

- (UIImageView *)thumb
{
    if (!_thumb){
        _thumb = [[UIImageView alloc] init];
//        _thumb.layer.cornerRadius = 30;
    }
    return _thumb;
}

-(UILabel *)tips
{
    if (!_tips){
        _tips = [[UILabel alloc] init];
        _tips.textColor = [UIColor colorWithHexString:@"#999999"];
        _tips.font = [UIFont systemFontOfSize:14];
     }
    return _tips;
}

- (void)setModel:(AEModelTemplate *)model
{
    _thumb.image = model.image;
    _tips.text   = model.txt;
    if (!model.txt || model.txt.length == 0){
        _tips.hidden = YES;
        [self.thumb mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
        }];
        _isOrigin = YES;
    }else{
        _isOrigin = NO;
        _tips.hidden = NO;
        
        [self.thumb mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self.mas_top).offset(38);
        }];
        
        [self.tips mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self.mas_top).offset(88);
        }];
        
    }
}

- (void)setSelected:(BOOL)selected{
    
    [super setSelected:selected];
    if (selected) {
        [self onSelected];
    }else{
        [self onUnselected];
    }
}
- (void)onSelected
{
    if (_isOrigin) return ;
    self.thumb.layer.borderColor = [UIColor colorWithHexString:@"#ff2e42"].CGColor;
    self.thumb.layer.borderWidth = 2;
    self.tips.textColor = [UIColor colorWithHexString:@"#ff2e42"];
}

- (void)onUnselected
{
    if (_isOrigin) return ;
    self.thumb.layer.borderColor = [[UIColor clearColor]CGColor];
    self.thumb.layer.borderWidth = 0;
    self.tips.textColor = [UIColor colorWithHexString:@"#999999"];
    
}
@end
