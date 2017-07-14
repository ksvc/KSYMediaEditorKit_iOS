//
//  KSYEditBGMCell.h
//  demo
//
//  Created by sunyazhou on 2017/7/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYAudioEffectDelegate.h"
#import "KSYBGMusicViewDelegate.h"

@interface KSYEditBGMCell : UICollectionViewCell
@property(nonatomic, weak) id <KSYBGMusicViewDelegate> delegate;
@property(nonatomic, weak) id <KSYAudioEffectDelegate> audioEffectDelegate;
@end
