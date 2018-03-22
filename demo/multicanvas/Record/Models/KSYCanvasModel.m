//
//  KSYCanvasModel.m
//  multicanvas
//
//  Created by sunyazhou on 2017/11/27.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYCanvasModel.h"



@interface KSYCanvasModel ()

@property(nonatomic, strong)AVAssetImageGenerator *imageGenerator;
@end

@implementation KSYCanvasModel

- (void)gengrateImageBySize:(CGSize)size
          completionHandler:(CompletionHandler)handler{
    if (self.videoURL == nil) { handler(nil); }
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:self.videoURL];
    self.imageGenerator = nil;
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    self.imageGenerator.maximumSize = size;
    
    NSError *error=nil;
    CMTime time= kCMTimeZero;//CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
    CMTime actualTime;
    CGImageRef cgImage= [self.imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if(error){
        NSLog(@"截取视频缩略图时发生错误，错误信息：%@",error.localizedDescription);
        handler(nil);
        return;
    }
    CMTimeShow(actualTime);
    UIImage *image = [UIImage imageWithCGImage:cgImage];//转化为UIImage
    CGImageRelease(cgImage);
    handler(image);
}
@end
