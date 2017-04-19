//
//  UIImage+Add.m
//  demo
//
//  Created by 张俊 on 10/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "UIImage+Add.h"

@implementation UIImage (Add)


+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL
                             atTime:(NSTimeInterval)time
{
    
    UIImage *thumbnailImage = nil;
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    if (!asset) return nil;
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    imageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *err = nil;
    thumbnailImageRef = [imageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 1)
                                               actualTime:NULL
                                                    error:&err];
    
    if (!thumbnailImageRef){
        NSLog(@"thumbnailImageGenerationError %@", err);
        return nil;
    }else{
        thumbnailImage =[[UIImage alloc] initWithCGImage:thumbnailImageRef];
        CGImageRelease(thumbnailImageRef);
    }
    
    return thumbnailImage;
}

@end
