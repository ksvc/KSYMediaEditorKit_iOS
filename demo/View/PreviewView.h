//
//  PreviewView.h
//  demo
//
//  Created by 张俊 on 05/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PreViewSubViewIdx){
    PreViewSubViewIdx_Close,
    PreViewSubViewIdx_ToggleCamera,
    PreViewSubViewIdx_Flash,
    PreViewSubViewIdx_Record,
    PreViewSubViewIdx_LoadFile,
    PreViewSubViewIdx_DeleteRecFile,
    PreViewSubViewIdx_Save2Edit,
    PreViewSubViewIdx_beauty
};

@interface PreviewView : UIView

@property (nonatomic, strong)UIButton *closeBtn;

@property (nonatomic, strong)UIButton *toggleCameraBtn;

@property (nonatomic, strong)UIButton *flashBtn;

@property (nonatomic, strong)UIButton *beautyBtn;

@property (nonatomic, strong)UIButton *recordBtn;

@property (nonatomic, strong)UIButton *loadFileBtn;

@property (nonatomic, strong)UILabel  *recordTimeLabel;

//删除录制的视频
@property (nonatomic, strong)UIButton *deleteBtn;

@property (nonatomic, strong)UIButton *saveBtn;

@property (nonatomic, strong)UIView *previewView;



@property (nonatomic, copy) void (^onEvent)(PreViewSubViewIdx idx, int extra);

@end
