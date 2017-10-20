//
//  KSYEditVideoTrimCell.h
//  demo
//
//  Created by sunyazhou on 2017/7/14.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KSYEditTrimDelegate.h"

@interface KSYEditVideoTrimCell : UICollectionViewCell

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, weak) id <KSYEditTrimDelegate> delegate;

@end
