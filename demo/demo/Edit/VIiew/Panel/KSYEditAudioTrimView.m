//
//  KSYEditAudioTrimView.m
//  demo
//
//  Created by sunyazhou on 2017/7/19.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYEditAudioTrimView.h"

#import <KSYAudioPlotView/KSYAudioPlot.h>

static CGFloat kTrimPadding  = 28;
static CGFloat kTrimMinDuration = 5;

typedef NS_ENUM(NSInteger, KSYEditDragView){
    KSYEditDragViewUnknow = 0,
    KSYEditDragViewLeftThumb = 1,
    KSYEditDragViewRightThumb = 2
};


@interface KSYEditAudioTrimView () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet KSYAudioPlotView *audioPlotView;
@property (nonatomic, strong) KSYAudioFile *audioFile;

@property (weak, nonatomic) IBOutlet UIImageView *leftThumb;
@property (weak, nonatomic) IBOutlet UIImageView *rightThumb;

@property (nonatomic, strong) MASConstraint *leftConstraint;
@property (nonatomic, strong) MASConstraint *topConstraint;

@property (nonatomic, strong) MASConstraint *rightConstraint;

@property (nonatomic, strong) UIPanGestureRecognizer *panGes;

@property (nonatomic, strong) UIView *leftMask;
@property (nonatomic, strong) UIView *rightMask;

@property (nonatomic, assign) CMTime duration;

@property (nonatomic, assign) KSYEditDragView dragInRangeView;
@end

@implementation KSYEditAudioTrimView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self configAudioView];
    self.backgroundColor = [UIColor ksy_colorWithHex:0x07080B andAlpha:0.8];
    self.audioFile = nil;
    
    self.dragInRangeView = KSYEditDragViewUnknow;
}

- (void)configAudioView{
    
    //
    // Customizing the audio plot's look
    //
    
    //
    // Background color
    //
    self.audioPlotView.backgroundColor = [UIColor clearColor];
    
    //
    // Waveform color
    //
    self.audioPlotView.color = [UIColor colorWithHexString:@"#DCDCDC"];
    
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
    self.audioPlotView.waveformLayer.shadowColor = [UIColor colorWithHexString:@"#DCDCDC"].CGColor;
    self.audioPlotView.waveformLayer.shadowOpacity = 5.0;
    self.audioPlotView.waveformLayer.lineWidth = 3;
    
    //    [self.audioPlotView mas_makeConstraints:^(MASConstraintMaker *make) {
    //
    //        make.left.right.equalTo(self.view);
    //        make.centerX.equalTo(self.view.mas_centerX);
    //        make.centerY.equalTo(self.view.mas_centerY);
    //        make.height.equalTo(@80);
    //    }];
    
    
    [self.audioPlotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, kTrimPadding, 0, kTrimPadding));
    }];
    
    //左侧推子
    [self.leftThumb mas_makeConstraints:^(MASConstraintMaker *make) {
        // 设置边界条件约束，保证内容可见，优先级1000
        make.left.greaterThanOrEqualTo(self.mas_left);
        make.right.lessThanOrEqualTo(self.rightThumb.mas_left).offset(-kTrimMinDuration);
        make.top.greaterThanOrEqualTo(self.mas_top);
        make.bottom.lessThanOrEqualTo(self.mas_bottom);
        
        _leftConstraint = make.centerX.equalTo(self.mas_left).with.offset(0).priorityHigh(); // 优先级要比边界条件低
        _topConstraint = make.centerY.equalTo(self.mas_top).with.offset(0).priorityHigh(); // 优先级要比边界条件低
        make.width.mas_equalTo(@(kTrimPadding));
        make.height.mas_equalTo(self.mas_height);
    }];
    
    //右侧推子
//    self.rightThumb.frame = CGRectMake(kScreenWidth-20, 0, 20, 60);
    [self.rightThumb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_lessThanOrEqualTo(self.mas_right);
        make.left.greaterThanOrEqualTo(self.leftThumb.mas_right).offset(kTrimMinDuration);
        make.top.greaterThanOrEqualTo(self.mas_top);
        make.bottom.lessThanOrEqualTo(self.mas_bottom);
        
        _rightConstraint = make.centerX.equalTo(self.mas_left).with.offset(kScreenWidth-kTrimMinDuration).priorityMedium();
        make.width.mas_equalTo(@(kTrimPadding));
        make.height.mas_equalTo(self.mas_height);
    }];
    
    
    self.panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftPanWithGesture:)];
    
    self.panGes.delegate = self;
    [self addGestureRecognizer:self.panGes];
    
    self.leftMask = [[UIView alloc] initWithFrame:CGRectZero];
    self.rightMask = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.leftMask];
    [self addSubview:self.rightMask];
    
    [self.leftMask mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.right.equalTo(self.leftThumb.mas_left);
    }];
    self.leftMask.backgroundColor = [UIColor ksy_colorWithHex:0x07080B andAlpha:0.6];
    
    self.rightMask.backgroundColor = [UIColor ksy_colorWithHex:0x07080B andAlpha:0.6];
//    self.rightMask.frame = CGRectMake(kScreenWidth, 0, 0, 60)
    [self.rightMask mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self);
        make.left.equalTo(self.rightThumb.mas_right);
    }];
}

- (void)openFileWithFilePathURL:(NSURL*)filePathURL
{
    //    if (filePathURL) {
    //        MediaMetaInfo *info = [KSYMediaHelper audioMetaFrom:filePathURL];
    //        self.duration = info.duration;
    //
    //    }
    
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
    
    AVAsset *as = [AVAsset assetWithURL:[NSURL fileURLWithPath:[filePathURL absoluteString]]];
    self.duration = [as duration];
    [self resetViews];
}


/**
 还原滑条默认位置
 */
- (void)resetViews{
    _leftConstraint.offset = 0;
    _rightConstraint.offset = kScreenWidth;
//    self.rightThumb.left = self.width - self.rightThumb.width;
//    self.rightMask.left = self.rightThumb.right;
}

#pragma mark - Pan gesture

- (void)leftPanWithGesture:(UIPanGestureRecognizer *)pan {
    CGPoint draggingPoint = [pan locationInView:self];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        if (CGRectContainsPoint(self.leftThumb.frame, draggingPoint)) {
            self.dragInRangeView = KSYEditDragViewLeftThumb;
        }
        if (CGRectContainsPoint(self.rightThumb.frame, draggingPoint)) {
            self.dragInRangeView = KSYEditDragViewRightThumb;
        }
        if ([self.delegate respondsToSelector:@selector(editTrimWillStartSeekType:)]){
            [self.delegate editTrimWillStartSeekType:KSYMEEditTrimTypeAudio];
        }
    }
    
    if (self.dragInRangeView == KSYEditDragViewLeftThumb) {
        _leftConstraint.offset = draggingPoint.x;
        _topConstraint.offset = draggingPoint.y;
        
        if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
            if (self.duration.value > 0) {
                CGFloat leftTimeX = self.leftThumb.right;
                if (leftTimeX <= kTrimPadding) {
                    leftTimeX = kTrimPadding;
                }
                
                CGFloat rightTimeX = self.rightThumb.left;
                if (rightTimeX >= (self.width - self.rightThumb.width)) {
                    rightTimeX = (self.width - self.rightThumb.width);
                }
                
                CMTime leftStartTime = CMTimeMultiplyByFloat64(self.duration, (leftTimeX - kTrimPadding)/self.audioPlotView.width);
                CMTime rightEndTime = CMTimeMultiplyByFloat64(self.duration, (rightTimeX - kTrimPadding)/self.audioPlotView.width);
                [self notifyDelegate:leftStartTime endTime:rightEndTime];
                //            NSLog(@"左侧裁剪区间:%.2f|%.2f",CMTimeGetSeconds(leftStartTime),CMTimeGetSeconds(rightEndTime));
            }
        }
        //        NSLog(@"左侧推子的X坐标:%.2f",self.leftThumb.right);
    } else if (self.dragInRangeView == KSYEditDragViewRightThumb){
        CGPoint velocity = [pan velocityInView:self.rightThumb];
        _rightConstraint.offset = draggingPoint.x;
        if(velocity.x > 0)
        {
//            CGPoint rightPoint  = [self convertPoint:draggingPoint toView:self.rightThumb];
            NSLog(@"gesture went right");
            
//            CGFloat x = fmin(draggingPoint.x, kScreenWidth - rightPoint.x);
//            self.rightThumb.centerX = x;
        }
        else
        {
//            CGFloat x = fmax(draggingPoint.x, self.leftThumb.right + self.rightThumb.width);
//            self.rightThumb.centerX = x;
            NSLog(@"gesture went left");
        }
//        self.rightMask.left = self.rightThumb.right;
//        self.rightMask.width = kScreenWidth - self.rightThumb.right;
        
        if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
            if (self.duration.value > 0) {
                CGFloat leftTimeX = self.leftThumb.right;
                if (leftTimeX <= kTrimPadding) {
                    leftTimeX = kTrimPadding;
                }
                
                CGFloat rightTimeX = self.rightThumb.left;
                if (rightTimeX >= (self.width - self.rightThumb.width)) {
                    rightTimeX = (self.width - self.rightThumb.width);
                }
                
                CMTime leftStartTime = CMTimeMake(self.duration.value * (leftTimeX - kTrimPadding)/self.audioPlotView.width, self.duration.timescale);
                
                CMTime rightEndTime = CMTimeMake(self.duration.value * (rightTimeX - kTrimPadding)/self.audioPlotView.width, self.duration.timescale);
                
                //            NSLog(@"右侧裁剪区间:%.2f|%.2f",CMTimeGetSeconds(leftStartTime),CMTimeGetSeconds(rightEndTime));
                
                [self notifyDelegate:leftStartTime endTime:rightEndTime];
                
            }
        }
        
        //        NSLog(@"右侧推子的X坐标:%.2f",self.rightThumb.left);
    } else {
        NSLog(@"其它View pan:%@",NSStringFromCGPoint(draggingPoint));
    }
}


- (void)notifyDelegate:(CMTime)startTime endTime:(CMTime)endTime{
    self.dragInRangeView = KSYEditDragViewUnknow;
    
    if ([self.delegate respondsToSelector:@selector(editTrimType:range:)]) {
        [self.delegate editTrimType:KSYMEEditTrimTypeAudio range:CMTimeRangeFromTimeToTime(startTime, endTime)];
    }
}

#pragma mark -
#pragma mark - UIGestureRecognizer
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
//    if (gestureRecognizer == self.panGes) {
////        UIPanGestureRecognizer *pan =  (UIPanGestureRecognizer *)gestureRecognizer;
//
//        return YES;
//    }
//
//    return NO;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    if (otherGestureRecognizer.view != self) {
//        return NO;
//    }
//    return NO;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    
//    return YES;
//}
@end
