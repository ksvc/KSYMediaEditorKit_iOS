//
//  KSYInputCfgModel.h
//  demo
//
//  Created by sunyazhou on 2017/10/27.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSYInputCfgModel : NSObject
@property (nonatomic, assign) CGFloat pixelWidth;//分辨率 宽 默认：720
@property (nonatomic, assign) CGFloat pixelHeight;//分辨率 高 默认: 1280
@property (nonatomic, assign) CGFloat videoKbps;//视频码率
@property (nonatomic, assign) BOOL footerVideo; //片尾视频
@end
