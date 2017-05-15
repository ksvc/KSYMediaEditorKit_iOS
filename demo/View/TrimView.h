//
//  TrimView.h
//  demo
//
//  Created by 张俊 on 03/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TrimType){
    TrimLeft,
    TrimRight,
    TrimBoth, //移动
};
@protocol TrimViewDelegate <NSObject>

/**
 裁剪进度条 param are all in [0.0f -1.0f]

 @param from range start
 @param to   range end
 */
-(void)trim2Range:(CGFloat)from to:(CGFloat)to;


/**
 trim触发事件
 @param type 参考TrimType
 @param to 某个点，播放器响应该事件，触发后seek到相应时间点
 @param dur 裁剪的范围比例[0-1]
 */
- (void)onTrim:(TrimType)type from:(CGFloat)from to:(CGFloat)to dur:(CGFloat)dur;


@end

@interface TrimView : UIView

//左时间刻度
@property(nonatomic, strong)UILabel *startTime;

//右时间刻度
@property(nonatomic, strong)UILabel *endTime;

//裁剪时间结果&提示
@property(nonatomic, strong)UILabel *tipView;

//2个bar之间的最小距离
@property(nonatomic, assign)CGFloat minDuration;

@property(nonatomic, assign)CGFloat startTimeRatio;

@property(nonatomic, assign)CGFloat endTimeRatio;

//add subView  on this view
@property(nonatomic, strong)UIView *thumbnailBgView;

@property (nonatomic, weak) id <TrimViewDelegate>delegate;

@end
