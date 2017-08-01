//
//  KSYEditTrimDelegate.h
//  demo
//
//  Created by sunyazhou on 2017/7/17.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KSYMediaEditorKit/KSYDefines.h>
#
@protocol KSYEditTrimDelegate <NSObject>

@optional
- (void)editTrimWillStartSeekType:(KSYMEEditTrimType)type;
- (void)editTrimType:(KSYMEEditTrimType)type range:(CMTimeRange)range;

- (void)didChangeResizeMode:(KSYMEResizeMode)mode;
- (void)didChangeRatio:(KSYMEResizeRatio)ratio;
@end
