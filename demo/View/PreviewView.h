//
//  PreviewView.h
//  demo
//
//  Created by 张俊 on 05/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordProgressView.h"
#import "VideoMgrButton.h"

typedef NS_ENUM(NSUInteger, PreViewSubViewIdx){
    PreViewSubViewIdx_Close,
    PreViewSubViewIdx_ToggleCamera,
    PreViewSubViewIdx_Flash,
    PreViewSubViewIdx_Record,
    PreViewSubViewIdx_LoadFile,
    PreViewSubViewIdx_DeleteRecFile,
    PreViewSubViewIdx_BackRecFile,
    PreViewSubViewIdx_Save2Edit,
    PreViewSubViewIdx_beauty
};

@interface PreviewView : UIView

//初始化录制进度条
- (void)initRecrdProgress:(CGFloat)minIndicator;

@property (nonatomic, strong)UIButton *closeBtn;

@property (nonatomic, strong)UIButton *toggleCameraBtn;

@property (nonatomic, strong)UIButton *flashBtn;

@property (nonatomic, strong)UIButton *beautyBtn;

@property (nonatomic, strong)UIButton *recordBtn;

@property (nonatomic, strong)UILabel  *recordTimeLabel;

//@property (nonatomic, strong)UIButton *loadFileBtn;
//删除录制的视频
//@property (nonatomic, strong)UIButton *deleteBtn;
@property (nonatomic, strong)VideoMgrButton *videoMgrBtn;

@property (nonatomic, strong)UIButton *saveBtn;

@property (nonatomic, strong)UIView   *previewView;

@property (nonatomic, strong)RecordProgressView *progress;

@property (nonatomic, copy) void (^onEvent)(PreViewSubViewIdx idx, int extra);

@end
