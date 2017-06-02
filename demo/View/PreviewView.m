//
//  PreviewView.m
//  demo
//
//  Created by 张俊 on 05/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "PreviewView.h"
#import "RecordProgressView.h"


@interface PreviewView ()
{
    

}

@end

@implementation PreviewView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubviews];
    }
    return self;
}


- (void)initRecrdProgress:(CGFloat)minIndicator
{
    if (!_progress){
        _progress = [[RecordProgressView alloc] initWithFrame:CGRectMake(16, kScreenSizeHeight - 130, kScreenSizeWidth - 32, 16) minIndicator:minIndicator*(kScreenSizeWidth - 32)];
    }
    [self addSubview:_progress];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.previewView.frame = self.frame;
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-25);
        make.top.mas_equalTo(self).offset(25);
    }];
    
    [self.toggleCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.closeBtn.mas_left).offset(-12);
        make.centerY.mas_equalTo(self.closeBtn);
        make.width.height.equalTo(self.closeBtn);
    }];
    
    [self.flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.toggleCameraBtn.mas_left).offset(-12);
        make.centerY.mas_equalTo(self.closeBtn);
        make.width.height.equalTo(self.closeBtn);
    }];
    
    [self.recordTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.top.mas_equalTo(self.closeBtn.mas_bottom).offset(10);
        
        make.right.mas_equalTo(self.closeBtn.mas_right);
    }];

    [self.recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.centerX.mas_equalTo(self);
        make.width.height.mas_equalTo(75);
        make.centerY.mas_equalTo(self.mas_bottom).offset(-60);
        
    }];
    
    [self.videoMgrBtn mas_makeConstraints:^(MASConstraintMaker *make) {

        make.bottom.mas_equalTo(self.recordBtn.mas_top).offset(-48);
        
        make.centerX.mas_equalTo(self.mas_left).offset(kScreenSizeWidth/8);
        
    }];
    
    // 美颜
    [self.beautyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.mas_equalTo(self.mas_left).offset(kScreenSizeWidth*3/8);
        make.centerY.mas_equalTo(self.videoMgrBtn);
        
    }];
    
    [self.bgmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.mas_equalTo(self.mas_left).offset(kScreenSizeWidth*5/8);
        make.centerY.mas_equalTo(self.videoMgrBtn);
    }];
    
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.mas_equalTo(self.mas_left).offset(kScreenSizeWidth*7/8);
        make.centerY.mas_equalTo(self.videoMgrBtn);
    }];
}

- (void)addSubviews
{
    self.backgroundColor = [UIColor blackColor];
    [self addSubview:self.previewView];
    [self addSubview:self.closeBtn];
    [self addSubview:self.toggleCameraBtn];
    [self addSubview:self.recordTimeLabel];
    [self addSubview:self.flashBtn];
    [self addSubview:self.recordBtn];
    [self addSubview:self.videoMgrBtn];
    [self addSubview:self.bgmBtn];
    [self addSubview:self.saveBtn];
    [self addSubview:self.beautyBtn];
    
    self.recordTimeLabel.hidden = YES;
    

}

- (UIButton *)closeBtn
{
    if (!_closeBtn){
        _closeBtn = [UIButton  buttonWithType:UIButtonTypeCustom];
        _closeBtn.tag = PreViewSubViewIdx_Close;
        [_closeBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setImage:[UIImage imageNamed:@"record_close"] forState:UIControlStateNormal];
    }
    return _closeBtn;
}

-(UIButton *)toggleCameraBtn
{
    if (!_toggleCameraBtn){
        _toggleCameraBtn = [UIButton  buttonWithType:UIButtonTypeCustom];
        _toggleCameraBtn.tag = PreViewSubViewIdx_ToggleCamera;
        [_toggleCameraBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [_toggleCameraBtn setImage:[UIImage imageNamed:@"living_lens"] forState:UIControlStateNormal];
        
    }
    return _toggleCameraBtn;
}


-(UIButton *)flashBtn
{
    if (!_flashBtn){
        _flashBtn = [UIButton  buttonWithType:UIButtonTypeCustom];
        _flashBtn.tag = PreViewSubViewIdx_Flash;
        [_flashBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [_flashBtn setImage:[UIImage imageNamed:@"living_flash_sel"] forState:UIControlStateNormal];
    
    }
    return _flashBtn;
}

- (UIButton *)recordBtn
{
    if (!_recordBtn){
        _recordBtn = [UIButton  buttonWithType:UIButtonTypeCustom];
        _recordBtn.tag = PreViewSubViewIdx_Record;
        [_recordBtn addTarget:self action:@selector(onStartRec:) forControlEvents:UIControlEventTouchDown];
        [_recordBtn addTarget:self action:@selector(onStopRec:)forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [_recordBtn setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
        [_recordBtn setImage:[UIImage imageNamed:@"recording"] forState:UIControlStateHighlighted];
        
        
    }
    return _recordBtn;
}

- (UIButton *)bgmBtn
{
    if (!_bgmBtn){
        _bgmBtn = [UIButton  buttonWithType:UIButtonTypeCustom];
        _bgmBtn.tag = PreViewSubViewIdx_Bgm;
        [_bgmBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bgmBtn setImage:[UIImage imageNamed:@"BgmBtn"] forState:UIControlStateNormal];
    }
    return _bgmBtn;
}


- (VideoMgrButton *)videoMgrBtn
{
    if (!_videoMgrBtn){
        _videoMgrBtn = [[VideoMgrButton alloc] init];
        [_videoMgrBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoMgrBtn;
}



-(UILabel *)recordTimeLabel
{
    if (!_recordTimeLabel){
        _recordTimeLabel = [[UILabel alloc] init];
        _recordTimeLabel.text = [NSString stringWithHMS:0];
        _recordTimeLabel.textColor = [UIColor blackColor];
        _recordTimeLabel.font = [UIFont systemFontOfSize:20];
        _recordTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _recordTimeLabel;

}

- (UIButton *)beautyBtn
{
    if (!_beautyBtn) {
        _beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _beautyBtn.tag = PreViewSubViewIdx_beauty;
        [_beautyBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [_beautyBtn setImage:[UIImage imageNamed:@"filterBtn"] forState:UIControlStateNormal];
    }
    return _beautyBtn;
}

- (UIButton *)saveBtn
{
    if (!_saveBtn){
        _saveBtn = [UIButton  buttonWithType:UIButtonTypeCustom];
        _saveBtn.tag = PreViewSubViewIdx_Save2Edit;
        [_saveBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_saveBtn setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
    }
    return _saveBtn;
}

- (UIView *)previewView
{
    if (!_previewView){
        _previewView = [[UIView alloc] init];
        _previewView.backgroundColor = [UIColor blackColor];
    }
    return _previewView;
    
}

- (void)onStartRec:(UIButton *)sender
{
    if (self.onEvent){
        self.onEvent(sender.tag, 0);
    }
}

- (void)onStopRec:(UIButton *)sender
{
    if (self.onEvent){
        self.onEvent(sender.tag, 1);
    }
}

- (void)onClick:(UIButton *)sender
{
    if (self.onEvent){

        self.onEvent(sender.tag, 0);
    }

}


@end
