//
//  AERootView.h
//  demo
//
//  Created by 张俊 on 20/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AEModelTemplate.h"
#import "BgmSelectorView.h"

typedef NS_ENUM(NSInteger, KSYSelectorType){
    KSYSelectorType_Reverb,     // 混响
    KSYSelectorType_AE,         // 音效
    KSYSelectorType_BGM,        // 背景音
    KSYSelectorType_Decal,      // 贴纸
    KSYSelectorType_TextDecal,  // 字幕
};

typedef NS_ENUM(NSUInteger, kAEStatus){
    kAEHidden,
    kAEShow,
};

@interface AERootView : UIView

@property(nonatomic, strong)BgmSelectorView *bgmView;

/// invokes after changeing bgm volume
@property (nonatomic, copy)void(^BgmVolumeBlock)(float origin, float dub);

/// invokes after selecting bgm
@property (nonatomic, copy)void(^BgmBlock)(AEModelTemplate *model);

/// invokes after selecting audio effect
@property (nonatomic, copy)void(^AEBlock)(AEModelTemplate *model);

/// invokes after selecting DecalView & TextDecalView
@property (nonatomic, copy)void(^DEBlock)(AEModelTemplate *model);

@end
