//
//  KSYRecordAudioEffectView.h
//  demo
//
//  Created by sunyazhou on 2017/7/11.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYAudioEffectDelegate.h"

@interface KSYRecordAudioEffectView : UIView

@property(nonatomic, weak) id <KSYAudioEffectDelegate> delegate;

@end
