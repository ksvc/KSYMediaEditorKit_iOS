//
//  RecordConfigCell.m
//  demo
//
//  Created by sunyazhou on 2017/7/4.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "RecordConfigCell.h"

CGFloat kRecordCfgCellColumnSpace = 10;

@interface RecordConfigCell () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *pixelLabel;
@property (weak, nonatomic) IBOutlet UILabel *fpsLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoBitrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *audioBitrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *orientationLabel;
@property (weak, nonatomic) IBOutlet UITextField *fpsTextField;
@property (weak, nonatomic) IBOutlet UITextField *videoBitrateTextField;
@property (weak, nonatomic) IBOutlet UITextField *audioBitrateTextField;
@property (weak, nonatomic) IBOutlet UILabel *videoBitrateKbps;
@property (weak, nonatomic) IBOutlet UILabel *audioBitrateKbps;


@property (nonatomic, strong) HMSegmentedControl *pixelSegment;
@property (nonatomic, strong) HMSegmentedControl *orientationSegment;

@property (nonatomic, strong) NSMutableArray *pixelModelArray;
@property (nonatomic, strong) NSMutableArray *orientationModelArray;

@end

@implementation RecordConfigCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.pixelModelArray = [NSMutableArray arrayWithObjects:@"540P",@"720P",@"1080P", nil];
    self.orientationModelArray = [NSMutableArray arrayWithObjects:@"竖屏",@"横屏", nil];
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
    
    
    //帧率相关
    [self.fpsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.pixelLabel);
        make.top.equalTo(self.pixelLabel.mas_bottom).offset(kRecordCfgCellColumnSpace);
        make.height.equalTo(self.pixelLabel.mas_height);
    }];
    
    [self.fpsTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fpsLabel.mas_top);
        make.left.equalTo(self.pixelSegment.mas_left);
        make.height.equalTo(self.pixelSegment.mas_height);
        make.width.equalTo(@50);
    }];
    
    //视频码率相关
    [self.videoBitrateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.fpsLabel);
        make.top.equalTo(self.fpsLabel.mas_bottom).offset(kRecordCfgCellColumnSpace);
        make.height.equalTo(self.fpsLabel.mas_height);
    }];
    [self.videoBitrateTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoBitrateLabel.mas_top);
        make.left.equalTo(self.fpsTextField.mas_left);
        make.height.equalTo(self.fpsTextField.mas_height);
        make.width.equalTo(@80);
    }];
    [self.videoBitrateKbps mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoBitrateTextField.mas_top);
        make.left.equalTo(self.videoBitrateTextField.mas_right).offset(kRecordCfgCellColumnSpace);
        make.height.equalTo(self.videoBitrateTextField.mas_height);
        make.width.equalTo(@50);
    }];
    
    //音频码率相关
    [self.audioBitrateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.videoBitrateLabel);
        make.top.equalTo(self.videoBitrateLabel.mas_bottom).offset(kRecordCfgCellColumnSpace);
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
        make.left.equalTo(self.audioBitrateTextField.mas_right).offset(kRecordCfgCellColumnSpace);
        make.height.equalTo(self.audioBitrateTextField.mas_height);
        make.width.equalTo(@50);
    }];
    
    //横竖屏
    [self.orientationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.audioBitrateLabel);
        make.top.equalTo(self.audioBitrateLabel.mas_bottom).offset(kRecordCfgCellColumnSpace);
        make.height.equalTo(self.audioBitrateLabel.mas_height);
    }];
    
    self.orientationSegment = [[HMSegmentedControl alloc] initWithSectionTitles:self.orientationModelArray];
    self.orientationSegment.frame = CGRectMake(0, 20, self.contentView.width, 40);
    self.orientationSegment.backgroundColor = [UIColor colorWithHexString:@"#08080b"];
    self.orientationSegment.selectionStyle = HMSegmentedControlSelectionStyleArrow;
    self.orientationSegment.selectionIndicatorLocation =     HMSegmentedControlSelectionIndicatorLocationDown;
    self.orientationSegment.selectionIndicatorColor = [UIColor colorWithHexString:@"#ff214e"];
    self.orientationSegment.shouldAnimateUserSelection = NO;
    self.orientationSegment.selectionIndicatorBoxColor = [UIColor colorWithHexString:@"#414353"];
    [self.orientationSegment setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = nil;
        if (selected) {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
            
        }else {
            attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#9b9b9b"],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        }
        
        return attString;
    }];
    
    [self.orientationSegment addTarget:self
                          action:@selector(orientationSegmentChangedValue:)
                forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.orientationSegment];
    
    [self.orientationSegment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.orientationLabel.mas_top);
        make.left.equalTo(self.audioBitrateTextField.mas_left);
        make.height.equalTo(self.audioBitrateTextField.mas_height);
        make.width.equalTo(@140);
    }];
    
    self.fpsTextField.delegate = self;
    self.videoBitrateTextField.delegate = self;
    self.audioBitrateTextField.delegate = self;
    
    UIColor *tfColor =  [UIColor colorWithHexString:@"#1b1b22"];
    self.fpsTextField.backgroundColor = tfColor;
    self.videoBitrateTextField.backgroundColor = tfColor;
    self.audioBitrateTextField.backgroundColor = tfColor;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

- (void)setModel:(RecordConfigModel *)model{
    _model = model;
    self.pixelSegment.selectedSegmentIndex = model.resolution;
    self.fpsTextField.text = model.fps > 0?[NSString stringWithFormat:@"%zd",model.fps]:@"";
    self.videoBitrateTextField.text = model.videoKbps > 0?[NSString stringWithFormat:@"%.0f",model.videoKbps]:@"";
    self.audioBitrateTextField.text = model.audioKbps > 0?[NSString stringWithFormat:@"%.0f",model.audioKbps]:@"";
    self.orientationSegment.selectedSegmentIndex = model.orientation;
}

- (void)pixelSegmentChangedValue:(HMSegmentedControl *)segment{
    self.model.resolution = segment.selectedSegmentIndex;
    [self notifyDelegate];
}

- (void)orientationSegmentChangedValue:(HMSegmentedControl *)segment{
    self.model.orientation = segment.selectedSegmentIndex;
    [self notifyDelegate];
}


- (void)notifyDelegate{
    if ([self.delegate respondsToSelector:@selector(recordConfigCell:recordModel:)]) {
        [self.delegate recordConfigCell:self recordModel:self.model];
    }
}
#pragma mark -
#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    self.model.fps = [self.fpsTextField.text integerValue];
    self.model.videoKbps = [self.videoBitrateTextField.text floatValue];
    self.model.audioKbps = [self.audioBitrateTextField.text floatValue];
    [self notifyDelegate];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    self.model.fps = [self.fpsTextField.text integerValue];
    self.model.videoKbps = [self.videoBitrateTextField.text floatValue];
    self.model.audioKbps = [self.audioBitrateTextField.text floatValue];
    [self notifyDelegate];
    return [textField resignFirstResponder];
    
}



@end
