//
//  KSYEditPanelView.h
//  demo
//
//  Created by sunyazhou on 2017/7/12.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYAudioEffectDelegate.h"
#import "KSYEditStickDelegate.h"
#import "KSYEditWatermarkCellDelegate.h"
#import "KSYEditTrimDelegate.h"
#import "KSYEditLevelDelegate.h"
#import "KSYEditSpeedLevelModel.h"
#import "KSYEditFilterEffectCell.h"

extern NSString * const kKSYEditPanelTitleBeauty;
extern NSString * const kKSYEditPanelTitleWatermark;
extern NSString * const kKSYEditPanelTitleMultiple;
extern NSString * const kKSYEditPanelTitleVideoTrim;
extern NSString * const kKSYEditPanelTitleMusic;
extern NSString * const kKSYEditPanelTitleChangeVoice;
extern NSString * const kKSYEditPanelTitleReverb;
extern NSString * const kKSYEditPanelTitleStricker;
extern NSString * const kKSYEditPanelTitleSubtitle;
extern NSString * const kKSYEditPanelTitleAnimationImage;
extern NSString * const kKSYEditPanelTitleFilterEffect;

@class KSYEditPanelView;
@protocol KSYEditPanelViewDelegate <NSObject>

@optional

//page滑动
- (void)editPanelView:(KSYEditPanelView *)view scrollPage:(NSUInteger)page;

//美颜代理
- (void)editPanelView:(KSYEditPanelView *)view
           filterType:(KSYMEBeautyKindType)type;

/**
 背景音乐的代理方法
 
 @param view 面板视图
 @param filePath 音乐本地路径
 */
- (void)editPanelView:(KSYEditPanelView *)view songFilePath:(NSString *)filePath;

/**
 音乐 代理方法
 
 @param view 面板视图
 @param type 音量类型
 @param value 变化的value
 */
- (void)editPanelView:(KSYEditPanelView *)view
      audioVolumnType:(KSYMEAudioVolumnType)type
             andValue:(float)value;
@end

@interface KSYEditPanelView : UIView
@property (nonatomic, strong, readonly) NSArray *titles;
@property (nonatomic, strong, readonly) NSArray *panelHeights; //所有面板的高度

@property (nonatomic, weak) id <KSYEditPanelViewDelegate> delegate;
@property (nonatomic, weak) id <KSYAudioEffectDelegate> audioEffectDelegate;
@property (nonatomic, weak) id <KSYEditStickDelegate> stickerDelegate;
@property (nonatomic, weak) id <KSYEditWatermarkCellDelegate> watermarkDelegate;
@property (nonatomic, weak) id <KSYEditTrimDelegate> videoTrimDelegate;
@property (nonatomic, weak) id <KSYEditLevelDelegate> levelDelegate;
@property (nonatomic, weak) id <KSYEditFilterEffectCellDelegate> filterEffectDelegate;
@property (nonatomic, strong) NSURL *trimVideoURL;
@property (nonatomic, strong) KSYEditSpeedLevelModel *levelModel; //倍速模型
@property (nonatomic, assign) BOOL showWatermark;
/**
 获取当前面板高度

 @param index 选择的面板索引
 @return 高度
 */
- (CGFloat)panelHeightForIndex:(NSUInteger)index;

/**
 通过tab切换的索引更换layout布局

 @param index 底部面板tabbar切换索引
 */
- (void)changeLayoutByIndex:(NSUInteger)index;

@end
