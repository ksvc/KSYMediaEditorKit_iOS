//
//  KSYEffectLineView.h
//  demo
//
//  Created by sunyazhou on 2017/12/20.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KSYEffectLineViewProtocol.h"

typedef NS_ENUM(NSUInteger, KSYEffectLineCursorStatus) {
    KSYELViewCursorStatusDrawNone  = 0,  //游标空闲
    KSYELViewCursorStatusDrawBegan = 1,  //游标开始绘制
    KSYELViewCursorStatusDrawing   = 2,  //游标绘制中
    KSYELViewCursorStatusDrawEnd   = 3   //游标结束绘制
};

typedef NS_ENUM(NSUInteger, KSYEffectLineType){
    KSYEffectLineTypeUndo       = 0,//撤销
    KSYEffectLineTypeShake      = 1,//抖动
    KSYEffectLineTypeSoulOut    = 2,//灵魂出窍
    KSYEffectLineTypeShockWave  = 3,//冲击波
    KSYEffectLineTypeBlackMagic = 4, //black magic
    KSYEffectLineTypeLightning  = 5,//闪电
    KSYEffectLineTypeBlackKTV   = 6 //KTV
};



//----------------------------------------
//----------------------------------------
//----------------------------------------
@interface KSYEffectLineView : UIView

@property (nonatomic, strong) NSURL  *url;
@property (nonatomic, weak  ) id <KSYEffectLineViewProtocol> delegate;

@property (nonatomic, assign) CMTime duraiton;

- (void)startEffectByURL:(NSURL *)url;

- (void)seekToTime:(Float64)time;

- (void)drawViewByStatus:(KSYEffectLineCursorStatus)status
                andColor:(UIColor *)drawColor
                 forType:(KSYEffectLineType)type;
/**
 移出最新绘制的视图
 */
- (void)removeLastDrawViews;

/**
 移除所有已绘制的视图
 */
- (void)removeAllDrawViews;

- (NSArray<KSYEffectLineInfo *>*)getAllDrawedInfos;
@end


//----------------------------------------
//----------------------------------------
//----------------------------------------
@interface KSYEffectLineInfo : NSObject

@property (nonatomic, assign) KSYEffectLineType type;
@property (nonatomic, assign) Float64 startTime;
@property (nonatomic, assign) Float64 endTime;
@property (nonatomic, assign) NSUInteger drawViewIndex; //标识 view 的索引在 绘制的父视图中
@end

