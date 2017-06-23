//
//  AudioTrimView.m
//  demo
//
//  Created by sunyazhou on 2017/6/16.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "AudioTrimView.h"

@interface AudioTrimView ()

// An EZAudioFile that will be used to load the audio file at the file path specified
//
@property (nonatomic, strong) KSYAudioFile *audioFile;
@property (strong, nonatomic) KSYAudioPlotView *audioPlotView;
    
@end

@implementation AudioTrimView

    
- (void)awakeFromNib {
    [super awakeFromNib];
    
    
    
    self.audioTrim.frame = CGRectMake(0, 0, kScreenSizeWidth, 125);
    
    
}
    
- (void)setupSubviews {
    //
    // Customizing the audio plot's look
    //
    
    //
    // Background color
    //
    self.audioPlotView.backgroundColor = [UIColor colorWithRed: 0.169 green: 0.643 blue: 0.675 alpha: 1];
    
    //
    // Waveform color
    //
    self.audioPlotView.color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    //
    // Plot type
    //
    self.audioPlotView.plotType = KSYPlotTypeBuffer;
    
    //
    // Fill
    //
    self.audioPlotView.shouldFill = YES;
    
    //
    // Mirror
    //
    self.audioPlotView.shouldMirror = YES;
    
    //
    // No need to optimze for realtime
    //
    self.audioPlotView.shouldOptimizeForRealtimePlot = NO;
    
    //
    // Customize the layer with a shadow for fun
    //
    self.audioPlotView.waveformLayer.shadowOffset = CGSizeMake(0.0, 1.0);
    self.audioPlotView.waveformLayer.shadowRadius = 0.0;
    self.audioPlotView.waveformLayer.shadowColor = [UIColor colorWithRed: 0.069 green: 0.543 blue: 0.575 alpha: 1].CGColor;
    self.audioPlotView.waveformLayer.shadowOpacity = 5.0;
    self.audioPlotView.waveformLayer.lineWidth = 3;
    
    self.audioPlotView.layer.masksToBounds = YES;
    //
    // Load in the sample file
    //
    
}
    
#pragma mark - Action Extensions
    //------------------------------------------------------------------------------
    
- (void)openFileWithFilePathURL:(NSURL*)filePathURL
    {
        self.audioFile = nil;
        self.audioFile = [KSYAudioFile audioFileWithURL:filePathURL];
        
        
        //
        // Plot the whole waveform
        //
        self.audioPlotView.plotType = KSYPlotTypeBuffer;
        self.audioPlotView.shouldFill = YES;
        self.audioPlotView.shouldMirror = YES;
        
        //
        // Get the audio data from the audio file
        //
        __weak typeof (self) weakSelf = self;
        [self.audioFile getWaveformDataWithCompletionBlock:^(float **waveformData,
                                                             int length)
         {
             [weakSelf.audioPlotView updateBuffer:waveformData[0]
                               withBufferSize:length];
         }];
    }
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)showWaveByURL:(NSURL *)url{
    if (url == nil) { return; }
    if ([self.audioTrim.thumbnailBgView.subviews containsObject:self.audioPlotView]) {
        self.audioPlotView.frame = CGRectMake(0, 0, self.audioTrim.thumbnailBgView.frame.size.width, 50);
        [self.audioTrim.thumbnailBgView bringSubviewToFront:self.audioPlotView];
        
    } else {
        self.audioPlotView  = [[KSYAudioPlotView alloc] initWithFrame:CGRectMake(0, 0, self.audioTrim.thumbnailBgView.frame.size.width, 50)];
        [self.audioTrim.thumbnailBgView addSubview:self.audioPlotView];
        
    }
    [self setupSubviews];
    
    
    [self openFileWithFilePathURL:url];
}
@end
