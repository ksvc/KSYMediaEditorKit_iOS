//
//  KSYAssetImageGenerator.h
//  demo
//
//  Created by sunyazhou on 2017/10/19.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
typedef NS_ENUM(NSUInteger, KSYAssetInfoType) {
    KSYAssetInfoTypeVideo,
    KSYAssetInfoTypeImage
};

@interface KSYAssetInfo : NSObject
@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) KSYAssetInfoType type;
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat animDuration;

- (UIImage *)captureImageAtTime:(CGFloat)time outputSize:(CGSize)outputSize;
-(CGFloat)realDuration;

@end

@interface KSYAssetImageGenerator : NSObject
@property (nonatomic) CGSize outputSize;
@property (nonatomic) NSInteger imageCount;
@property (nonatomic, assign) CGFloat duration;

- (void)addVideoWithPath:(NSString *)path startTime:(CGFloat)startTime duration:(CGFloat)duration animDuration:(CGFloat)animDuration;
- (void)addImageWithPath:(NSString *)path duration:(CGFloat)duration animDuration:(CGFloat)animDuration;
- (void)generateWithCompleteHandler:(void(^)(UIImage *))handler;
- (void)cancel;

@end
