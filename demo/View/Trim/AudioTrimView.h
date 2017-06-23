//
//  AudioTrimView.h
//  demo
//
//  Created by sunyazhou on 2017/6/16.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrimView.h"

#import <KSYAudioPlotView/KSYAudioPlot.h>

@interface AudioTrimView : UIView

@property (weak, nonatomic) IBOutlet TrimView *audioTrim;

- (void)showWaveByURL:(NSURL *)url;
@end
