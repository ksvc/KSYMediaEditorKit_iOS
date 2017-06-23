//
//  UIImage+Add.h
//  demo
//
//  Created by 张俊 on 10/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Add)

+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL
                             atTime:(NSTimeInterval)time;

@end
