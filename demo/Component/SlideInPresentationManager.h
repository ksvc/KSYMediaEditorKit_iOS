//
//  SlideInPresentationManager.h
//  Nemo
//
//  Created by sunyazhou on 2017/6/9.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//  本章用到的知识点请点击https://www.raywenderlich.com/139277/uipresentationcontroller-tutorial-getting-started查看

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PresentationDirection){
    PresentationDirectionLeft = 1,
    PresentationDirectionRight = 2,
    PresentationDirectionTop = 3,
    PresentationDirectionBottom = 4
};

@interface SlideInPresentationManager : NSObject <UIViewControllerTransitioningDelegate,UIAdaptivePresentationControllerDelegate>


/**
 展露转成的方向
 */
@property(nonatomic, assign) PresentationDirection direction;


/**
 是否支持紧凑高度
 */
@property(nonatomic, assign) BOOL disableCompactHeight;

/**
 滑动展露的系数 比如 从方向是底部present出一个控制器 想让出现的控制器的高度范围是
 屏幕的几分之几的话 ,那么这个系数就传 一个 0~1之间 比如 1/3 那么就是1.0/3.0
 
 不接受负数
 */
@property(nonatomic, assign) CGFloat sliderRate; //默认值 1.0/3.0


/**
 显示黑色遮盖视图 点击自动返回  如果设置NO 则外部自己负责返回 内部将不再支持自动手势点击dismiss
 默认yes
 */
@property(nonatomic, assign) BOOL showDimView;


/**
 暗影后边的containView是否全屏 如果不是全屏 则跟随 控制器的范围显示
 如果这个属性被设置 那么sliderRate系数将作用于显示该范围
 默认YES
 */
@property(nonatomic, assign) BOOL containerViewSizeToFit;



@end


