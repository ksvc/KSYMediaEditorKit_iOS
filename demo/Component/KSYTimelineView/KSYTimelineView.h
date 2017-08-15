//
//  KSYTimelineView.h
//  demo
//
//  Created by sunyazhou on 2017/8/2.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KSYTimelineMediaInfo.h"
#import "KSYTimelineComposition.h"

@protocol KSYTimelineViewDelegate;

@interface KSYTimelineView : UIView
@property (nonatomic, weak) id<KSYTimelineViewDelegate> delegate;
@property (nonatomic, copy) NSString *leftPinchImageName;
@property (nonatomic, copy) NSString *rightPinchImageName;
@property (nonatomic, copy) NSString *pinchBgImageName;
@property (nonatomic, strong) UIColor *indicatorColor;
@property (nonatomic, strong) UIColor *pinchBgColor;
@property (nonatomic, assign) CGFloat actualDuration;

/**
 初始化方法
 
 @param size 大小
 @param urls 视频地址 可能是多段 传数组
 @param segment 段长 （指的是一个屏幕宽度的视频长度 单位为 s）
 @param photosPersegment 一个段长上要显示几张图片 暂时默认8张
 @return
 */
//- (id)initWithSize:(CGSize)size videoUrls:(NSArray *)urls rotate:(NSInteger)rotate segment:(CGFloat)segment photosPersegment:(NSInteger)photos;


/**
 装载数据，用来显示
 
 @param urls 视频地址
 @param segment 段长（指的是一个屏幕宽度的视频时长  单位：s）
 @param photos 一个段长上需要显示的图片个数 默认为8
 */
- (void)setupVideoUrls:(NSArray *)urls segment:(CGFloat)segment photosPersegent:(NSInteger)photos;


/**
 装载数据，用来显示
 
 @param clips 媒体片段
 @param segment 段长（指的是一个屏幕宽度的视频时长  单位：s）
 @param photos 一个段长上需要显示的图片个数 默认为8
 */
- (void)setMediaClips:(NSArray<KSYTimelineMediaInfo *> *)clips segment:(CGFloat)segment photosPersegent:(NSInteger)photos;

/**
 获取当前时间指针所指向的时间
 
 @return 时间
 */
- (CGFloat)getCurrentTime;

/**
 视频播放过程中，传入当前播放的时间，导航条进行相应的展示
 
 @param time 当前播放时间
 */
- (void)seekToTime:(CGFloat)time;


/**
 取消当前控件行为 例如：在滑动时，调用此方法则不再滑动
 */
- (void)cancel;

/**
 添加显示元素 （例如加动图后，需要构建timelineItem对象，并且传入用来显示）
 
 @param timelineItem 显示元素
 */
- (void)addTimelineItem:(KSYMETimeLineItem *)timelineItem;

/**
 删除显示元素
 
 @param timelineItem 显示元素
 */
- (void)removeTimelineItem:(KSYMETimeLineItem *)timelineItem;

/**
 传入Timeline进入编辑
 
 @param timelineItem timelineItem
 */
- (void)editTimelineItem:(KSYMETimeLineItem *)timelineItem;

/**
 timelineView编辑完成
 */
- (void)editTimelineComplete;

/**
 从vid获取KSYTimelineItem对象
 
 @param obj obj
 @return KSYMETimeLineItem
 */
- (KSYMETimeLineItem *)getTimelineItemWithOjb:(id)obj;



/**
 更新透明度
 
 @param alpha 透明度
 */
- (void)updateTimelineViewAlpha:(CGFloat)alpha;

/**
 获取所有已添加到时间线上的 item
 
 @return KSYMETimeLineItem
 */
- (NSMutableArray <KSYMETimeLineItem *>*)getAllAddedItems;

@end




/////////////////////////////////////////////////////////////
//////////--KSYTimelineViewDelegate--////////////////////////
/////////////////////////////////////////////////////////////

@protocol KSYTimelineViewDelegate <NSObject>

/**
 回调拖动的item对象（在手势结束时发生）
 
 @param item timeline对象
 */
- (void)timelineDraggingTimelineItem:(KSYMETimeLineItem *)item;


/**
 回调timeline开始被手动滑动
 */
- (void)timelineBeginDragging;

- (void)timelineDraggingAtTime:(CGFloat)time;

- (void)timelineEndDraggingAndDecelerate:(CGFloat)time;

- (void)timelineCurrentTime:(CGFloat)time duration:(CGFloat)duration;

@end
