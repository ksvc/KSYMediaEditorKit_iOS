//
//  KSYInputCfgCell.m
//  demo
//
//  Created by sunyazhou on 2017/10/27.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYInputCfgCell.h"

@interface KSYInputCfgCell() <UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UILabel *pixelLabel;
@property (weak, nonatomic) IBOutlet UITextField *pixelWidthTextField;
@property (weak, nonatomic) IBOutlet UITextField *pixelHeightTextField;



@property (weak, nonatomic) IBOutlet UILabel *videoRateLabel;

@property (weak, nonatomic) IBOutlet UITextField *videoRateTextField;
@property (weak, nonatomic) IBOutlet UILabel *videokbpsLabel;
@property (weak, nonatomic) IBOutlet UISwitch *sw;



@end

@implementation KSYInputCfgCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.pixelWidthTextField.delegate = self;
    self.pixelHeightTextField.delegate = self;
    self.videoRateTextField.delegate = self;
}

/**
 UI布局代码 不用关注
 */
- (void)configSubviews{
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

- (void)setModel:(KSYInputCfgModel *)model{
    _model = model;
    
    self.pixelWidthTextField.text = [NSString stringWithFormat:@"%.0f",model.pixelWidth];
    self.pixelHeightTextField.text = [NSString stringWithFormat:@"%.0f",model.pixelHeight];
    
    self.videoRateTextField.text = [NSString stringWithFormat:@"%.0f",model.videoKbps];
    
    
    [self.sw setOn:model.footerVideo animated:YES];
    [self setNeedsDisplay];
    [self layoutIfNeeded];
}

- (IBAction)footerValueChange:(UISwitch *)sender {
    self.model.footerVideo = sender.on;
    [self notifyDelegate];
}


- (void)notifyDelegate{
    if ([self.delegate respondsToSelector:@selector(inputConfigCell:cfgModel:)]) {
        [self.delegate inputConfigCell:self cfgModel:self.model];
    }
}

#pragma mark -
#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    self.model.pixelWidth = [self.pixelWidthTextField.text floatValue];
    self.model.pixelHeight = [self.pixelHeightTextField.text floatValue];
    self.model.videoKbps = [self.videoRateTextField.text floatValue];
    [self notifyDelegate];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    self.model.pixelWidth = [self.pixelWidthTextField.text floatValue];
    self.model.pixelHeight = [self.pixelHeightTextField.text floatValue];
    self.model.videoKbps = [self.videoRateTextField.text floatValue];
    [self notifyDelegate];
    return [textField resignFirstResponder];
}



@end
