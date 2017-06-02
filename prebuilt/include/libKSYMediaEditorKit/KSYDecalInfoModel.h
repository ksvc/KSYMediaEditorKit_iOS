//
//  KSYDecalInfoModel.h
//  KSYMediaEditorKit
//
//  Created by iVermisseDich on 2017/5/17.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import "GPUImagePicture.h"
@interface KSYDecalInfoModel : NSObject

// 贴纸图片
@property (nonatomic) GPUImagePicture *pic;

@property (nonatomic, assign) CGRect rect;

@property (nonatomic, assign) CGFloat alpha;

#pragma mark - 以下接口暂不支持
@property (nonatomic, assign) CMTimeRange displayTimeRange;

@end
