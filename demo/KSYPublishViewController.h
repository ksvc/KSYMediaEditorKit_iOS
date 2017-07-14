//
//  KSYPublishViewController.h
//  demo
//
//  Created by iVermisseDich on 2017/7/10.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSYPublishViewController : UIViewController

- (instancetype)initWithUrl:(NSURL *)path coverImage:(UIImage *)coverImage;

- (instancetype)initWithGif:(NSURL *)path;

@end
