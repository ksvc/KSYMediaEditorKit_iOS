//
//  KSYBGMusicView.h
//  demo
//
//  Created by sunyazhou on 2017/7/11.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYAudioEffectDelegate.h"
#import "KSYBGMusicViewDelegate.h"

@interface KSYBGMusicView : UIView
@property(nonatomic, weak) id <KSYBGMusicViewDelegate> delegate;
@property(nonatomic, weak) id <KSYAudioEffectDelegate> audioEffectDelegate;
@end
