//
//  VideoMetaHelper.m
//  demo
//
//  Created by 张俊 on 17/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "VideoMetaHelper.h"

@implementation VideoMetaInfo

@end


@implementation VideoMetaHelper

+ (VideoMetaInfo *)videoMetaFrom:(NSString *)path
{

    NSURL *url = [NSURL fileURLWithPath:path];
    VideoMetaInfo *info = [[VideoMetaInfo alloc] init];
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *track =  tracks.firstObject;
    info.naturalSize = track.naturalSize;
    
    CGAffineTransform tf = track.preferredTransform;
    CGFloat rotate = acosf(tf.a);
    if (tf.b < 0) {
        rotate = M_PI -rotate;
    }
    info.degree = rotate/M_PI * 180;
    return info;
}


@end
