//
//  OutputConfigCell.m
//  demo
//
//  Created by sunyazhou on 2017/7/4.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "OutputConfigCell.h"

CGFloat kOutputConfigCellColumnSpace = 10;

@interface OutputConfigCell () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *pixelLabel;
@property (weak, nonatomic) IBOutlet UILabel *encodeStyleLabel;

@property (weak, nonatomic) IBOutlet UILabel *videoBitrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *audioBitrateLabel;
@property (weak, nonatomic) IBOutlet UITextField *videoBitrateTextField;
@property (weak, nonatomic) IBOutlet UITextField *audioBitrateTextField;
@property (weak, nonatomic) IBOutlet UILabel *videoBitrateKbps;
@property (weak, nonatomic) IBOutlet UILabel *audioBitrateKbps;
@property (weak, nonatomic) IBOutlet UILabel *videoFormatLabel;
@property (weak, nonatomic) IBOutlet UILabel *audioFormatLabel;



@property (nonatomic, strong) HMSegmentedControl *pixelSegment;
@property (nonatomic, strong) HMSegmentedControl *encodeStyleSegment;
@property (nonatomic, strong) HMSegmentedControl *videoFormatSegment;
@property (nonatomic, strong) HMSegmentedControl *audioFormatSegment;

@property (nonatomic, strong) NSMutableArray *pixelModelArray;
@property (nonatomic, strong) NSMutableArray *encodeStyleModelArray;
@property (nonatomic, strong) NSMutableArray *videoFormatModelArray;
@property (nonatomic, strong) NSMutableArray *audioFormatModelArray;

@end
@implementation OutputConfigCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.pixelModelArray = [NSMutableArray arrayWithObjects:@"540P",@"720P",@"1080P", nil];
    self.encodeStyleModelArray = [NSMutableArray arrayWithObjects:@"H264",@"QY265",@"VT264",@"AUTO", nil];
    self.videoFormatModelArray = [NSMutableArray arrayWithObjects:@"MP4",@"GIF", nil];
    self.audioFormatModelArray = [NSMutableArray arrayWithObjects:@"AAC_HE",@"AAC",@"AT_ACC",@"AAC_HE_V2", nil];
    
    
    [self configSubviews];

}

/**
 UI布局代码 不用关注
 */
- (void)configSubviews{
    //分辨率相关
    [self.pixelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(20);
        make.top.mas_equalTo(self.mas_top).offset(20);
        make.width.equalTo(@80);
        make.height.equalTo(@28);
    }];
    self.pixelSegment = [[HMSegmentedControl alloc] initWithSectionTitles:self.pixelModelArray];
    self.pixelSegment.frame = CGRectMake(0, 20, self.contentView.width, 40);
    self.pixelSegment.backgroundColor = [UIColor colorWithHexString:@"#08080b"];
    self.pixelSegment.selectionStyle = HMSegmentedControlSelectionStyleArrow;
    self.pixelSegment.selectionIndicatorLocation =     HMSegmentedControlSelectionIndicatorLocationDown;
    self.pixelSegment.selectionIndicatorColor = [UIColor colorWithHexString:@"#ff214e"];
    self.pixelSegment.shouldAnimateUserSelection = NO;
    self.pixelSegment.selectionIndicatorBoxColor = [UIColor colorWithHexString:@"#414353"];
    [self.pixelSegment setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = nil;
        if (selected) {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
            
        }else {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#9b9b9b"],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        }
        
        return attString;
    }];
    
    [self.pixelSegment addTarget:self
                          action:@selector(pixelSegmentChangedValue:)
                forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.pixelSegment];
    
    [self.pixelSegment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.pixelLabel.mas_right).offset(0);
        make.top.bottom.mas_equalTo(self.pixelLabel);
        make.right.mas_equalTo(self.mas_right).offset(-20);
    }];
    
    
    //编码方式相关
    [self.encodeStyleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.pixelLabel.mas_left);
        make.top.mas_equalTo(self.pixelLabel.mas_bottom).offset(kOutputConfigCellColumnSpace);
        make.width.equalTo(self.pixelLabel.mas_width);
        make.height.equalTo(self.pixelLabel.mas_height);
    }];
    
    
    self.encodeStyleSegment = [[HMSegmentedControl alloc] initWithSectionTitles:self.encodeStyleModelArray];
    self.encodeStyleSegment.frame = CGRectMake(0, 20, self.contentView.width, 40);
    self.encodeStyleSegment.backgroundColor = [UIColor colorWithHexString:@"#08080b"];
    self.encodeStyleSegment.selectionStyle = HMSegmentedControlSelectionStyleArrow;
    self.encodeStyleSegment.selectionIndicatorLocation =     HMSegmentedControlSelectionIndicatorLocationDown;
    self.encodeStyleSegment.selectionIndicatorColor = [UIColor colorWithHexString:@"#ff214e"];
    self.encodeStyleSegment.shouldAnimateUserSelection = NO;
    self.encodeStyleSegment.selectionIndicatorBoxColor = [UIColor colorWithHexString:@"#414353"];
    [self.encodeStyleSegment setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = nil;
        if (selected) {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
            
        }else {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#9b9b9b"],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        }
        
        return attString;
    }];
    [self.encodeStyleSegment addTarget:self
                          action:@selector(encodeStyleSegmentChangedValue:)
                forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.encodeStyleSegment];
    
    [self.encodeStyleSegment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.encodeStyleLabel.mas_right).offset(0);
        make.top.bottom.mas_equalTo(self.encodeStyleLabel);
        make.right.equalTo(self.mas_right).offset(-20);
    }];

    //视频码率相关
    [self.videoBitrateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.encodeStyleLabel);
        make.top.equalTo(self.encodeStyleLabel.mas_bottom).offset(kOutputConfigCellColumnSpace);
        make.height.equalTo(self.encodeStyleLabel.mas_height);
    }];
    [self.videoBitrateTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoBitrateLabel.mas_top);
        make.left.equalTo(self.encodeStyleSegment.mas_left);
        make.height.equalTo(self.encodeStyleSegment.mas_height);
        make.width.equalTo(@80);
    }];
    [self.videoBitrateKbps mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoBitrateTextField.mas_top);
        make.left.equalTo(self.videoBitrateTextField.mas_right).offset(5);
        make.height.equalTo(self.videoBitrateTextField.mas_height);
        make.width.equalTo(@50);
    }];
    
    //音频码率相关
    [self.audioBitrateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.videoBitrateLabel);
        make.top.equalTo(self.videoBitrateLabel.mas_bottom).offset(kOutputConfigCellColumnSpace);
        make.height.equalTo(self.videoBitrateLabel.mas_height);
    }];
    [self.audioBitrateTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.audioBitrateLabel.mas_top);
        make.left.equalTo(self.videoBitrateTextField.mas_left);
        make.height.equalTo(self.videoBitrateTextField.mas_height);
        make.width.equalTo(@80);
    }];
    [self.audioBitrateKbps mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.audioBitrateLabel.mas_top);
        make.left.equalTo(self.audioBitrateTextField.mas_right).offset(5);
        make.height.equalTo(self.audioBitrateTextField.mas_height);
        make.width.equalTo(@50);
    }];
    
    //视频格式
    [self.videoFormatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.audioBitrateLabel);
        make.top.equalTo(self.audioBitrateLabel.mas_bottom).offset(kOutputConfigCellColumnSpace);
        make.height.equalTo(self.audioBitrateLabel.mas_height);
    }];
    
    self.videoFormatSegment = [[HMSegmentedControl alloc] initWithSectionTitles:self.videoFormatModelArray];
    self.videoFormatSegment.frame = CGRectMake(0, 20, self.contentView.width, 40);
    self.videoFormatSegment.backgroundColor = [UIColor colorWithHexString:@"#08080b"];
    self.videoFormatSegment.selectionStyle = HMSegmentedControlSelectionStyleArrow;
    self.videoFormatSegment.selectionIndicatorLocation =     HMSegmentedControlSelectionIndicatorLocationDown;
    self.videoFormatSegment.selectionIndicatorColor = [UIColor colorWithHexString:@"#ff214e"];
    self.videoFormatSegment.shouldAnimateUserSelection = NO;
    self.videoFormatSegment.selectionIndicatorBoxColor = [UIColor colorWithHexString:@"#414353"];
    [self.videoFormatSegment setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = nil;
        if (selected) {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
            
        }else {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#9b9b9b"],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        }
        
        return attString;
    }];

    [self.videoFormatSegment addTarget:self
                                action:@selector(videoFormatSegmentChangedValue:)
                      forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.videoFormatSegment];
    
    [self.videoFormatSegment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoFormatLabel.mas_top);
        make.left.equalTo(self.audioBitrateTextField.mas_left);
        make.height.equalTo(self.audioBitrateTextField.mas_height);
        make.width.equalTo(@160);
    }];
    
    
    UIColor *tfColor =  [UIColor colorWithHexString:@"#1b1b22"];
    self.videoBitrateTextField.backgroundColor = tfColor;
    self.audioBitrateTextField.backgroundColor = tfColor;
    
    //音频格式
    [self.audioFormatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.videoFormatLabel);
        make.top.equalTo(self.videoFormatLabel.mas_bottom).offset(kOutputConfigCellColumnSpace);
        make.height.equalTo(self.videoFormatLabel.mas_height);
    }];
    
    
    self.audioFormatSegment = [[HMSegmentedControl alloc] initWithSectionTitles:self.audioFormatModelArray];
    self.audioFormatSegment.frame = CGRectMake(0, 20, self.contentView.width, 40);
    self.audioFormatSegment.backgroundColor = [UIColor colorWithHexString:@"#08080b"];
    self.audioFormatSegment.selectionStyle = HMSegmentedControlSelectionStyleArrow;
    self.audioFormatSegment.selectionIndicatorLocation =     HMSegmentedControlSelectionIndicatorLocationDown;
    self.audioFormatSegment.selectionIndicatorColor = [UIColor colorWithHexString:@"#ff214e"];
    self.audioFormatSegment.shouldAnimateUserSelection = NO;
    self.audioFormatSegment.selectionIndicatorBoxColor = [UIColor colorWithHexString:@"#414353"];
    [self.audioFormatSegment setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = nil;
        if (selected) {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
            
        }else {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#9b9b9b"],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        }
        
        return attString;
    }];
    
    [self.audioFormatSegment addTarget:self
                                action:@selector(audioFormatSegmentChangedValue:)
                      forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.audioFormatSegment];
    
    [self.audioFormatSegment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.audioFormatLabel.mas_top);
        make.left.equalTo(self.videoFormatSegment.mas_left);
        make.height.equalTo(self.videoFormatSegment.mas_height);
        make.right.equalTo(self.mas_right).offset(-20);
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.pixelSegment.selectedSegmentIndex = self.model.resolution;
    if (self.model.videoCodec == 100) {
        self.encodeStyleSegment.selectedSegmentIndex = 3;
    } else {
        self.encodeStyleSegment.selectedSegmentIndex = self.model.videoCodec;
    }
    self.videoBitrateTextField.text = self.model.videoKbps > 0?[NSString stringWithFormat:@"%.0f",self.model.videoKbps]:@"";
    self.audioBitrateTextField.text = self.model.audioKbps > 0?[NSString stringWithFormat:@"%.0f",self.model.audioKbps]:@"";
    self.videoFormatSegment.selectedSegmentIndex = self.model.videoFormat;
    
    self.videoBitrateTextField.delegate = self;
    self.audioBitrateTextField.delegate = self;
    
    self.audioFormatSegment.selectedSegmentIndex = self.model.audioCodec;
}

- (void)pixelSegmentChangedValue:(HMSegmentedControl *)segment{
    NSLog(@"分辨率切换");
    self.model.resolution = segment.selectedSegmentIndex;
    [self notifyDelegate];
}

- (void)encodeStyleSegmentChangedValue:(HMSegmentedControl *)segment{
    NSLog(@"编码方式切换");
    if (segment.selectedSegmentIndex == 3) {
        self.model.videoCodec = KSYVideoCodec_AUTO;
    }else{
        self.model.videoCodec = segment.selectedSegmentIndex;
    }
    [self notifyDelegate];
}

- (void)videoFormatSegmentChangedValue:(HMSegmentedControl *)segment{
    NSLog(@"视频格式切换");
    self.model.videoFormat = segment.selectedSegmentIndex;
    [self notifyDelegate];
}

- (void)audioFormatSegmentChangedValue:(HMSegmentedControl *)segment{
    NSLog(@"音频格式切换");
    self.model.audioCodec = segment.selectedSegmentIndex;
    [self notifyDelegate];
}

- (void)notifyDelegate{
    if ([self.delegate respondsToSelector:@selector(outputConfigCell:outputModel:)]) {
        [self.delegate outputConfigCell:self outputModel:self.model];
    }
}

#pragma mark -
#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    self.model.videoKbps = [self.videoBitrateTextField.text floatValue];
    self.model.audioKbps = [self.audioBitrateTextField.text floatValue];
    [self notifyDelegate];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    self.model.videoKbps = [self.videoBitrateTextField.text floatValue];
    self.model.audioKbps = [self.audioBitrateTextField.text floatValue];
    [self notifyDelegate];
    return [textField resignFirstResponder];
}
@end
