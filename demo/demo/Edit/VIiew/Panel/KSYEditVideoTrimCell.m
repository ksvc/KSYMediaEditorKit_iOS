//
//  KSYEditVideoTrimCell.m
//  demo
//
//  Created by sunyazhou on 2017/7/14.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEditVideoTrimCell.h"
#import <ICGVideoTrimmer/ICGVideoTrimmer.h>
#import <KSYMediaEditorKit/KSYDefines.h>

@interface KSYEditVideoTrimCell () <ICGVideoTrimmerDelegate>

@property (weak, nonatomic) IBOutlet ICGVideoTrimmerView *trimView;

@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIButton *fillBtn;
@property (weak, nonatomic) IBOutlet UIButton *clipBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ratioSegmentControl;

@property (assign, nonatomic) BOOL hasInitialed;
@end
@implementation KSYEditVideoTrimCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configSubviws];
}


- (void)configSubviws{
    
    [self.fillBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.right.equalTo(self.mas_centerX).offset(-10);
    }];
    _fillBtn.selected = YES;
    
    [self.clipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_fillBtn);
        make.left.equalTo(self.mas_centerX).offset(10);
    }];
    
    [self.ratioSegmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_fillBtn.mas_bottom).offset(5);
        make.centerX.equalTo(self);
    }];
    
    [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ratioSegmentControl.mas_bottom).offset(10);
        make.left.right.equalTo(self);
//        make.top.mas_equalTo(self.mas_top).offset(10);
        make.height.equalTo(@20);
    }];
    self.topLabel.textColor = [UIColor whiteColor];
    
    self.trimView.frame = CGRectMake(20, 150-120, kScreenWidth-40, 120);
    [self.trimView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(20);
        make.right.equalTo(self.mas_right).offset(-20);
        make.bottom.equalTo(self.mas_bottom).offset(-20);
        make.height.equalTo(@100);
    }];
    [self.trimView setDelegate:self];
    [self.trimView setThumbWidth:20];
    [self.trimView setThemeColor:[UIColor lightGrayColor]];
    [self.trimView hideTracker:YES];
    [self.trimView setShowsRulerView:YES];
    [self.trimView setTrackerColor:[UIColor clearColor]];
    [self.trimView setLeftThumbImage:[UIImage imageNamed:@"video_edit_trim_slider"]];
    [self.trimView setRightThumbImage:[UIImage imageNamed:@"video_edit_trim_slider"]];
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void)setVideoURL:(NSURL *)videoURL{
    if (_videoURL == videoURL) {
        return;
    }
    _videoURL = videoURL;
    
    AVURLAsset *asset = [AVAsset assetWithURL:self.videoURL];
    [self.trimView setAsset:asset];
    self.trimView.minLength = 1;
    self.trimView.maxLength = CMTimeGetSeconds([asset duration]);
    [self.trimView resetSubviews];
    _hasInitialed = YES;
    self.topLabel.text  = @"拖动两侧滑杆剪裁视频";
}

- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime{
    CMTime duration = trimmerView.asset.duration;
    CMTimeRange range =CMTimeRangeFromTimeToTime(CMTimeMake(startTime * duration.timescale, duration.timescale), CMTimeMake(endTime * duration.timescale, duration.timescale));
    if (_hasInitialed) {        
        if ([self.delegate respondsToSelector:@selector(editTrimType:range:)]) {
            [self.delegate editTrimType:KSYMEEditTrimTypeVideo range:range];
        }
    }
}

- (IBAction)didChangeResizeMode:(UIButton *)sender{
    KSYMEResizeMode mode = KSYMEResizeModeFill;
    if (sender == _fillBtn) {
        mode = KSYMEResizeModeFill;
        _fillBtn.selected = YES;
        _clipBtn.selected = NO;
    }else if (sender == _clipBtn){
        mode = KSYMEResizeModeClip;
        _fillBtn.selected = NO;
        _clipBtn.selected = YES;
    }
    
    if ([self.delegate respondsToSelector:@selector(didChangeResizeMode:)]) {
        [self.delegate didChangeResizeMode:mode];
    }
}
- (IBAction)didChangeRatio:(UISegmentedControl *)sender {
    if ([self.delegate respondsToSelector:@selector(didChangeRatio:)]) {
        [self.delegate didChangeRatio:(KSYMEResizeRatio)sender.selectedSegmentIndex];
    }
}

@end
