//
//  KSYTimelineComposition.h
//  demo
//
//  Created by sunyazhou on 2017/8/2.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSYTimelineMediaInfo.h"

typedef NS_ENUM(NSUInteger, kVideoDirection) {
    kVideoDirectionUnkown = 0,
    kVideoDirectionPortrait,
    kVideoDirectionPortraitUpsideDown,
    kVideoDirectionLandscapeRight,
    kVideoDirectionLandscapeLeft,
};

@interface KSYTimelineComposition : NSObject
@property (nonatomic, assign, readonly) double duration;

- (id)initWithClips:(NSArray *)clips;
//- (UIImage *)requestImageAtTime:(CGFloat)time;
- (void)generateImagesForTimes:(NSArray *)times
             completionHandler:(void (^) (UIImage *image, CGFloat requestTime))handler;

@end
