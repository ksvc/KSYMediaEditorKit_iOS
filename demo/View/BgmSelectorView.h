//
//  BgmSelectorView.h
//  demo
//
//  Created by 张俊 on 20/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AEMgrView.h"

@interface BgmSelectorView : UIView

@property(nonatomic, strong)AEMgrView *bgmView;

@property(nonatomic, strong)UISlider *originVolumeSlider;

@property(nonatomic, strong)UISlider *dubVolumeSlider;


@property (nonatomic, copy)void(^BgmVolumeBlock)(float origin, float dub);


@end
