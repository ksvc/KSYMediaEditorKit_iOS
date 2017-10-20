//
//  KSYTimelineMediaInfo.h
//  demo
//
//  Created by sunyazhou on 2017/8/2.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KSYMETimelineMediaInfoType){
    KSYMETimelineMediaInfoTypeVideo = 0,
    KSYMETimelineMediaInfoTypePhoto = 1,
};

@interface KSYTimelineMediaInfo : NSObject
@property (nonatomic, assign) KSYMETimelineMediaInfoType mediaType; //媒体类型 视频或者图片
@property (nonatomic, copy) NSString *path;     //媒体资源路径
@property (nonatomic, assign) CGFloat duration; //媒体持续时长
@property (nonatomic, assign) CGFloat startTime; //媒体开始时间
@property (nonatomic, assign) int rotate;//旋转角度
@end
