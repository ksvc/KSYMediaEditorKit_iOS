//
//  KSYEffectLineMaskView.h
//  demo
//
//  Created by sunyazhou on 2017/12/22.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYEffectLineView.h"

/**
 这里提供两个值给外部,哪个能用用哪个
 
 @param pointX 当前的 X 坐标
 @param ratio  当前的 X 坐标位置 和父视图宽度的比值
 */
typedef void (^KSYELMaskViewCursorBlock)(UIGestureRecognizerState state, CGFloat pointX, CGFloat ratio);

typedef void (^KSYELMaskViewDrawCompleteBlock)(KSYEffectLineInfo *info);

@interface KSYEffectLineMaskView : UIView

@property (nonatomic, copy) KSYELMaskViewCursorBlock        cursorBlock;
@property (nonatomic, copy) KSYELMaskViewDrawCompleteBlock  drawCompleteBlock;

@property (nonatomic, assign) CMTime duraiton;

@property (nonatomic, assign) BOOL needCountBlendUnion; //是否需要并集计算视图的
/**
 seek 位置

 @param time 值
 */
- (void)seekToCursorTime:(Float64)time;

- (void)drawView:(KSYEffectLineCursorStatus)status
        andColor:(UIColor *)drawColor
         forType:(KSYEffectLineType)type;


/**
 撤销最后一次绘制的视图
 */
- (void)undoDrawedView;


/**
 撤销所有已绘制的视图
 */
- (void)undoAllDrawedView;


/**
 获取已绘制的 Item 信息

 @return 当前已绘制好的所有范围
 */
- (NSArray<KSYEffectLineInfo *>*)getAllDrawedInfo;
@end
