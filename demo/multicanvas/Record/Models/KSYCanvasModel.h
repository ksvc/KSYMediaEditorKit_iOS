//
//  KSYCanvasModel.h
//  multicanvas
//
//  Created by sunyazhou on 2017/11/27.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

//| Cell Status | 当前cell显示内容 |其它 cell 显示内容| 点击当前cell | 点击其它cell |
//| :------: | :------: | :------: | :------: | :------: |
//| 无预览状态 | 显示加号/封面图 | 显示加号/或者封面 | 开始预览 | 切换预览视图 |
//| 正在预览状态 | 预览视频 | 显示加号/或者封面 | 显示加号/或者封面 | 切换预览视图 |
//| 录制状态 | 预览视频/播放视频 | (显示加号或播放视频)/(显示加号或预览视频) | 无操作(上锁) | 无操作(上锁) |

// UI比较复杂 目前的搞法使用 MVVM 的一点编程思路 用模型状态驱动 cell 变化(上边文本 markdown 直接可见)


#import <Foundation/Foundation.h>

typedef void (^CompletionHandler)(UIImage * image);

typedef NS_ENUM(NSUInteger,KSYMultiCanvasModelStatus){
    KSYMultiCanvasModelStatusNOPreview = 0,//无预览状态
    KSYMultiCanvasModelStatusINPreview = 1,//正在预览状态
    KSYMultiCanvasModelStatusRecording = 2 //正在录制状态
};

@interface KSYCanvasModel : NSObject 
@property (nonatomic, strong) NSURL  *videoURL;
@property (nonatomic, assign) BOOL   isSelected;
@property (nonatomic, assign) BOOL   isRecording;
@property (nonatomic, assign) CGSize resolution;//分辨率
@property (nonatomic, assign) CGRect region;//绘制区域 range 0 ~ 1
@property (nonatomic, assign) KSYMultiCanvasModelStatus modelStatus;
@property (nonatomic, assign) CGFloat leftChannelValue;
@property (nonatomic, assign) CGFloat rightChannelValue;
@property (nonatomic, assign) CGFloat pan; //声音环绕

- (void)gengrateImageBySize:(CGSize)size
          completionHandler:(CompletionHandler)handler;

@end
