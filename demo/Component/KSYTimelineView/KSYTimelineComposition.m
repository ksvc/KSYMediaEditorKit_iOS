//
//  KSYTimelineComposition.m
//  demo
//
//  Created by sunyazhou on 2017/8/2.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYTimelineComposition.h"

@implementation KSYTimelineComposition
{
    NSMutableArray *_composition;
}

- (id)initWithClips:(NSArray *)clips {
    if (self = [super init]) {
        
        double beginTime = 0;
        _composition = [[NSMutableArray alloc] init];
        
        for (int idx = 0; idx < [clips count]; idx++) {
            KSYTimelineMediaInfo *mediaInfo = clips[idx];
            if (mediaInfo.mediaType == KSYMETimelineMediaInfoTypeVideo) {
                AVMutableComposition *compsition = [AVMutableComposition composition];
                AVMutableCompositionTrack *compositionVideoTrack = [compsition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
                NSString *url = mediaInfo.path;
                AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:url] options:nil];
                CMTime assetDuration = [asset duration];
                AVAssetTrack *assetTrackVideo = nil;
                CGAffineTransform trans = CGAffineTransformIdentity;
                if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
                    assetTrackVideo = [asset tracksWithMediaType:AVMediaTypeVideo][0];
                    trans = [asset tracksWithMediaType:AVMediaTypeVideo][0].preferredTransform;
                }
                
                
                assetDuration = assetTrackVideo.timeRange.duration;
                CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, assetDuration);
                if (assetTrackVideo) {
                    [compositionVideoTrack insertTimeRange:timeRange ofTrack:assetTrackVideo atTime:kCMTimeZero error:nil];
                }
                
                double endtime = beginTime + CMTimeGetSeconds(assetDuration);
                
                NSString *key = [NSString stringWithFormat:@"%@-%@",@(beginTime), @(endtime)];
                NSDictionary *dict = @{key: compsition};
                [_composition addObject:dict];
                
                beginTime = endtime;
                _duration = endtime;
            } else {
                double endtime = beginTime + mediaInfo.duration;
                NSString *key = [NSString stringWithFormat:@"%@-%@", @(beginTime), @(endtime)];
                NSDictionary *dict = @{key : mediaInfo.path};
                [_composition addObject:dict];
                
                beginTime = endtime;
                _duration = endtime;
            }
        }
    }
    return self;
}

- (id)findCompsitionItemForTime:(CGFloat)time relativeTime:(CGFloat *)relativeTime {
    for (int idx = 0; idx < [_composition count]; idx++) {
        NSDictionary *dict = [_composition objectAtIndex:idx];
        NSString *key = [dict allKeys][0];
        double min = [[[key componentsSeparatedByString:@"-"] firstObject] doubleValue];
        double max = [[[key componentsSeparatedByString:@"-"] lastObject] doubleValue];
        if (time >= min && time < max) {//取缩略图：取头不取尾
            id value = [dict allValues][0];
            *relativeTime = time - min;
            return value;
        }
    }
    return nil;
}


- (void)generateImagesForTimes:(NSArray *)times completionHandler:(void (^)(UIImage *, CGFloat))handler {
    NSMutableArray *objs = [[NSMutableArray alloc] init];
    NSMutableArray *timeSet = [[NSMutableArray alloc] init];
    for (int idx = 0; idx < [times count]; idx++) {
        double time = [[times objectAtIndex:idx] doubleValue];
        CGFloat rTime = 0;
        id obj = [self findCompsitionItemForTime:time relativeTime:&rTime];
        
        id lastObj = [objs lastObject];
        
        if (lastObj == nil) {
            [objs addObject:obj];
            goto insert;
        } else {
            if (lastObj == obj) {
                goto insert;
            } else {
                [objs addObject:obj];
                goto insert;
            }
        }
        
    insert: {
        if ([timeSet count] <= [objs indexOfObject:obj]) {
            NSArray *setObjs = @[@(rTime)];
            [timeSet insertObject:setObjs atIndex:[objs indexOfObject:obj]];
        } else {
            id timeSetObj = [timeSet objectAtIndex:[objs indexOfObject:obj]];
            NSMutableArray *setMOjbs = [NSMutableArray arrayWithArray:timeSetObj];
            [setMOjbs addObject:@(rTime)];
            [timeSet replaceObjectAtIndex:[objs indexOfObject:obj] withObject:setMOjbs];
        }
    }
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);//这里这样写的目的主要是保证取出来的图片是顺序的
    dispatch_queue_t timelineQueue = dispatch_queue_create("com.duanqu.sdk.timeline", DISPATCH_QUEUE_SERIAL);
    dispatch_async(timelineQueue, ^{
        for (int idx = 0; idx < [objs count]; idx++ ) {
            id obj = [objs objectAtIndex:idx];
            id times = [timeSet objectAtIndex:idx];
            
            if ([obj isKindOfClass:[NSString class]]) {
                for (int p = 0; p < [times count]; p++) {
                    UIImage *image = [UIImage imageWithContentsOfFile:obj];
                    CGFloat imageRatio = image.size.width / image.size.height;
                    
                    CGSize newSize = CGSizeMake(100, 100);
                    
                    if (image.size.width > image.size.height) {
                        newSize.height = 100.0 / imageRatio;
                    } else {
                        newSize.width = 100.0 * imageRatio;
                    }
                    
                    UIGraphicsBeginImageContext(newSize);
                    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
                    UIImage *picture = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    NSData *imageData = UIImagePNGRepresentation(picture);
                    UIImage *img = [UIImage imageWithData:imageData];
                    
                    if (handler) {
                        handler(img, 0);
                    }
                }
            } else {
                AVMutableComposition *asset = (AVMutableComposition *)obj;
                AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                imageGenerator.appliesPreferredTrackTransform = YES;
                imageGenerator.maximumSize = CGSizeMake(100, 100);
                
                AVCompositionTrackSegment *seg = asset.tracks[0].segments[0];
                AVURLAsset *rAsset = [[AVURLAsset alloc] initWithURL:seg.sourceURL options:nil];
                
                CGAffineTransform trans = CGAffineTransformIdentity;
                if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
                    trans = [rAsset tracksWithMediaType:AVMediaTypeVideo][0].preferredTransform;
                }
                
                CGAffineTransform transform = [self transformFromRotate:[self getRotate:trans]];
                
                __block UIImage *tmpImage = nil;
                
                NSMutableArray *timeValues = [[NSMutableArray alloc] init];
                for (int j = 0; j < [times count]; j++ ) {
                    double time = [[times objectAtIndex:j] doubleValue];
                    CMTime cmTime = CMTimeMake(1000 * time, 1000);
                    [timeValues addObject:[NSValue valueWithCMTime:cmTime]];
                }
                __block int tmpIdx = 0;
                AVAssetImageGeneratorCompletionHandler completionHandler = ^(CMTime requestedTime, CGImageRef imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *err) {
                    if (result == AVAssetImageGeneratorSucceeded) {
                        @autoreleasepool {
                            CIImage *coreImage = [[CIImage imageWithCGImage:imageRef] imageByApplyingTransform:transform];
                            CIContext *context = [CIContext contextWithOptions:nil];
                            CGImageRef newImageRef = [context createCGImage:coreImage fromRect:[coreImage extent]];
                            UIImage *image = [UIImage imageWithCGImage:newImageRef];
                            tmpImage = image;
                            CGImageRelease(newImageRef);
                            if (handler) {
                                handler(image, 0);
                            }
                        }
                    } else {
                        if (tmpImage) {
                            if (handler) {
                                handler(tmpImage, 0);
                            }
                        }
                    }
                    tmpIdx++;
                    if (tmpIdx == [timeValues count]) {
                        dispatch_semaphore_signal(semaphore);
                    }
                };
                
                [imageGenerator generateCGImagesAsynchronouslyForTimes:timeValues completionHandler:completionHandler];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
        }
    });
}

- (kVideoDirection)getRotate:(CGAffineTransform)t
{
    if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
        return kVideoDirectionPortrait;
    }
    if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
        return kVideoDirectionPortraitUpsideDown;
    }
    if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
        return kVideoDirectionLandscapeLeft;
    }
    if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
        return kVideoDirectionLandscapeRight;
    }
    return kVideoDirectionUnkown;
}

- (CGAffineTransform)transformFromRotate:(kVideoDirection)rotate
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (rotate) {
        case kVideoDirectionPortrait: {
            transform = CGAffineTransformRotate(transform, -M_PI_2 );
        }
            break;
        case kVideoDirectionLandscapeLeft: {
            transform = CGAffineTransformRotate(transform, 0);
        }
            break;
        case kVideoDirectionPortraitUpsideDown: {
            transform = CGAffineTransformRotate(transform, M_PI_2);
        }
            break;
        case kVideoDirectionLandscapeRight: {
            transform = CGAffineTransformRotate(transform, M_PI);
        }
            break;
            
        default:
            break;
    }
    
    return transform;
}
@end
