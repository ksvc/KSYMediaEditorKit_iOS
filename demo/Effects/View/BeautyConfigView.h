//
//  BeautyConfigView.h
//  
//
//  Created by iVermisseDich on 16/12/7.
//  Copyright © 2016年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

// 美颜参数
typedef NS_ENUM(NSInteger, BeautyParameter) {
    BeautyParameterWhitening,
    BeautyParameterGrind,
    BeautyParameterRuddy
};

@protocol BeautyConfigViewDelegate <NSObject>

- (void)beautyParameter:(BeautyParameter)parameter valueDidChanged:(CGFloat)value;

@end



@interface BeautyConfigView : UIView

@property (nonatomic, weak) id <BeautyConfigViewDelegate>delegate;

@end
