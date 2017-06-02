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

typedef NS_ENUM(NSUInteger, kAEStatus){
    kAEHidden,
    kAEShow,
};

@interface AERootView : UIView

@property(nonatomic, strong)BgmSelectorView *bgmView;

@property (nonatomic, copy)void(^BgmVolumeBlock)(float origin, float dub);

@property (nonatomic, copy)void(^BgmBlock)(AEModelTemplate *model);

@property (nonatomic, copy)void(^AEBlock)(AEModelTemplate *model);
// DecalView
@property (nonatomic, copy)void(^DEBlock)(AEModelTemplate *model);

@end
