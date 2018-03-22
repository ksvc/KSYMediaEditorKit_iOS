//
//  KSYAssetImageGenerator.m
//  demo
//
//  Created by sunyazhou on 2017/10/19.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYAssetImageGenerator.h"

@interface KSYAssetImageGenerator ()
@property (nonatomic, strong) NSMutableArray<KSYAssetInfo *> *assets;
@property (nonatomic, assign) BOOL         shouldCancel;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation KSYAssetImageGenerator
-(instancetype)init {
    self = [super init];
    if (self) {
        _assets = [NSMutableArray array];
        _imageCount = 8;
        _outputSize = CGSizeMake(50, 50);
        _duration = 0;
    }
    return self;
}

-(void)addImageWithPath:(NSString *)path duration:(CGFloat)duration animDuration:(CGFloat)animDuration {
    KSYAssetInfo *info = [[KSYAssetInfo alloc] init];
    info.path = path;
    info.duration = duration;
    info.animDuration = animDuration;
    info.type = KSYAssetInfoTypeImage;
    [_assets addObject:info];
    _duration += [info realDuration];
}

-(void)addVideoWithPath:(NSString *)path startTime:(CGFloat)startTime duration:(CGFloat)duration animDuration:(CGFloat)animDuration {
    KSYAssetInfo *info = [[KSYAssetInfo alloc] init];
    info.path = path;
    info.duration = duration;
    info.animDuration = animDuration;
    info.startTime = startTime;
    info.type = KSYAssetInfoTypeVideo;
    [_assets addObject:info];
    _duration += [info realDuration];
}

-(void)generateWithCompleteHandler:(void(^)(UIImage *))handler {
    _shouldCancel = NO;
    _queue = dispatch_queue_create("com.ali.thumb.generator", NULL);
    __weak typeof(self) wself = self;
    dispatch_async(_queue, ^{
        CGFloat step = wself.duration/wself.imageCount;
        CGFloat currentDuration = 0;
        int index = 0;
        for (KSYAssetInfo *info in wself.assets) {
            CGFloat duration = [info realDuration];
            currentDuration += duration;
            int count = currentDuration / step;
            for (int i = index; i < count; i++) {
                CGFloat time = i*step-(currentDuration-duration);
                UIImage *image = [info captureImageAtTime:time outputSize:wself.outputSize];
                handler(image);
                if (wself.shouldCancel) break;
            }
            index = count;
            if (wself.shouldCancel) break;
        }
    });
}

-(void)cancel {
    _shouldCancel = YES;
}

@end


#pragma mark - KSYAssetInfo Class

@interface KSYAssetInfo ()
@property (nonatomic, strong) AVAssetImageGenerator *generator;
@end

@implementation KSYAssetInfo
- (void)dealloc{
    NSLog(@"KSYAssetInfo dealloc");
}

-(CGFloat)realDuration {
    return _duration - _animDuration;
}

- (UIImage *)captureImageAtTime:(CGFloat)time outputSize:(CGSize)outputSize {
    if (_type == KSYAssetInfoTypeImage) {
        return [self imageFromImageWithOutputSize:outputSize];
    }else {
        return [self imageFromVideoWithOutputSize:outputSize atTime:time];
    }
    
}

- (UIImage *)imageFromImageWithOutputSize:(CGSize)outputSize {
    UIImage *image = [UIImage imageWithContentsOfFile:_path];
    CGFloat imageRatio = image.size.width / image.size.height;
    if (image.size.width > image.size.height) {
        outputSize.height = outputSize.width / imageRatio;
    } else {
        outputSize.width = outputSize.height * imageRatio;
    }
    
    UIGraphicsBeginImageContext(outputSize);
    [image drawInRect:CGRectMake(0, 0, outputSize.width, outputSize.height)];
    UIImage *picture = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return picture;
}

- (UIImage *)imageFromVideoWithOutputSize:(CGSize)outputSize atTime:(CGFloat)atTime {
    if (!_generator) {
        _generator = [[AVAssetImageGenerator alloc] initWithAsset:[self composition]];
        _generator.maximumSize = outputSize;
        _generator.appliesPreferredTrackTransform = YES;
        _generator.requestedTimeToleranceAfter = kCMTimeZero;
        _generator.requestedTimeToleranceBefore = kCMTimeZero;
    }
    if (atTime < 0) {
        atTime = 0;
    }
    CMTime time = CMTimeMake(atTime * 1000, 1000);
    CGImageRef image = [_generator copyCGImageAtTime:time actualTime:NULL error:nil];
    UIImage *picture = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return picture;
}


-(AVComposition *)composition {
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:_path] options:nil];
    AVAssetTrack *assetTrackVideo = nil;
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetTrackVideo = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if (assetTrackVideo) {
        CMTime start = CMTimeMake((_startTime-_animDuration)*1000, 1000);
        CMTime duration = assetTrackVideo.timeRange.duration;
        if (_duration) {
            duration = CMTimeMake(_duration * 1000, 1000);
        }
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(start, duration) ofTrack:assetTrackVideo atTime:kCMTimeZero error:nil];
        compositionVideoTrack.preferredTransform = assetTrackVideo.preferredTransform;
        return composition;
    }
    return nil;
}


@end
