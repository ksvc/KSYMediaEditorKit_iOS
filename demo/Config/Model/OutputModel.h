//
//  OutputModel.h
//  demo
//
//  Created by sunyazhou on 2017/7/4.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecordConfigModel.h"
#import <libksygpulive/libksygpulive.h>


@interface OutputModel : NSObject
@property (nonatomic, assign) KSYRecordPreset resolution;     //分辨率
@property (nonatomic, assign) KSYVideoCodec videoCodec; //编码格式
@property (nonatomic, assign) KSYAudioCodec audioCodec; //音频格式
@property (nonatomic, assign) CGFloat videoKbps; //视频码率
@property (nonatomic, assign) CGFloat audioKbps; //音频码率
@property (nonatomic, assign) KSYOutputFormat videoFormat; //视频格式

- (CGSize)getResolutionFromPreset;

@end
