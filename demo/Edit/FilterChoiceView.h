//
//  FilterChoiceView.h
//  demo
//
//  Created by 张俊 on 06/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.

#import <UIKit/UIKit.h>

// 视图宽度
#define kBeautyCFGViewHeight 212

// 美颜参数
typedef NS_ENUM(NSInteger, BeautyParameter) {
    BeautyParameterWhitening,
    BeautyParameterGrind,
    BeautyParameterRuddy
};

@protocol FilterChoiceViewDelegate <NSObject>

- (void)beautyFilterDidSelected:(KSYFilter)algoType;
- (void)beautyParameter:(BeautyParameter)parameter valueDidChanged:(CGFloat)value;

@end



@interface FilterChoiceView : UIView

@property (nonatomic, weak) id <FilterChoiceViewDelegate>delegate;

// 美颜参数调节
@property (nonatomic, strong) UISlider *whiteningSlider;        // 美白 tag kBeautySliderTag
@property (nonatomic, strong) UISlider *grindSlider;            // 磨皮 tag:kBeautySliderTag+1
@property (nonatomic, strong) UISlider *ruddySlider;            // 红润 tag:kBeautySliderTag+2


@end
