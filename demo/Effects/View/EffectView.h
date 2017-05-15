//
//  BeautyConfigView.h
//  
//
//  Created by iVermisseDich on 16/12/7.
//  Copyright © 2016年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeautyConfigView.h"
#import "FilterView.h"
#import "StickerView.h"

// 视图宽度
#define kEffectCFGViewHeight 185.5


@interface EffectView : UIView

@property (nonatomic, strong) BeautyConfigView *beautyConfigView;// 美颜view
@property (nonatomic, strong) FilterView* filterView;//滤镜view
@property (nonatomic, strong) StickerView* stickerView;//贴纸view

@property (nonatomic, assign) BOOL beautyConfigViewIsShowing;

@end
