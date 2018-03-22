//
//  KSYEffectLineViewProtocol.h
//  demo
//
//  Created by sunyazhou on 2017/12/25.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>


@class KSYEffectLineView;
@class KSYEffectLineInfo;

typedef NS_ENUM(NSUInteger, KSYEffectLineCursorStatus);

@protocol KSYEffectLineViewProtocol <NSObject>

@optional
/**
 通知代理对象当前游标滑动的比例系数多少,业务方可通过 ratio 实现 seek 到指定位置.
 ratio 的计算是依据当前游标的 X 值 和 背景视图的宽度比例 eg: point.x / self.view.width

 @param effectLineView 控件实例
 @param ratio 游标滑动比例
 */
- (void)effectLineView:(KSYEffectLineView *)effectLineView
                 state:(UIGestureRecognizerState)state
       cursorMoveRatio:(CGFloat)ratio;

/**
 绘制过程中的状态变化代理回调 开始、过程中、结束.当完成的时候 info 才!=nil;
 @param effectLineView 控件实例
 @param st 手势状态
 @param info 完成的 model
 */
- (void)effectLineView:(KSYEffectLineView *)effectLineView
           actionState:(KSYEffectLineCursorStatus)st
      completeDrawInfo:(KSYEffectLineInfo *)info;

@end
